const { createRng, pick, intBetween } = require('./lib/rng');
const { estimatePrice } = require('./pricing');
const { distanceKm } = require('./lib/geo');

const SERVICES = [
  { key: 'fuel', name: 'Fuel Delivery', icon: '⛽', description: 'Petrol or diesel delivered to your location.', active: true },
  { key: 'battery', name: 'Battery Jump-Start', icon: '🔋', description: 'Get your battery jump-started on the spot.', active: true },
  { key: 'tire', name: 'Flat Tire Assistance', icon: '🛞', description: 'Tyre change or repair, roadside.', active: true },
  { key: 'mechanic', name: 'Minor Mechanical Assistance', icon: '🔧', description: 'Small mechanical issues fixed on the spot.', active: true },
  { key: 'towing', name: 'Towing', icon: '🚚', description: 'Vehicle towed to your nearest workshop.', active: true },
  { key: 'other', name: 'Other Problem', icon: '❓', description: "Not sure what's wrong? We'll still send help.", active: true },
];

const DEFAULT_RULE_BY_SERVICE = {
  fuel: { baseServiceFee: 180, perKmFee: 20, freeKm: 2, minFare: 0, nightSurchargeAmount: 150, cancellationFeeFlat: 100, platformCommissionPct: 0.12, fuelPricePerLitre: { petrol: 278, diesel: 288 } },
  battery: { baseServiceFee: 750, perKmFee: 15, freeKm: 2, minFare: 500, nightSurchargeAmount: 150, cancellationFeeFlat: 100, platformCommissionPct: 0.12 },
  tire: { baseServiceFee: 850, perKmFee: 15, freeKm: 2, minFare: 500, nightSurchargeAmount: 150, cancellationFeeFlat: 100, platformCommissionPct: 0.12 },
  mechanic: { baseServiceFee: 1100, perKmFee: 15, freeKm: 2, minFare: 700, nightSurchargeAmount: 150, cancellationFeeFlat: 100, platformCommissionPct: 0.13 },
  towing: { baseServiceFee: 1500, perKmFee: 60, freeKm: 1, minFare: 1500, nightSurchargeAmount: 250, cancellationFeeFlat: 200, platformCommissionPct: 0.15 },
  other: { baseServiceFee: 900, perKmFee: 15, freeKm: 2, minFare: 600, nightSurchargeAmount: 150, cancellationFeeFlat: 100, platformCommissionPct: 0.12 },
};

const CITIES = [
  { id: 'islamabad', name: 'Islamabad', enabled: true, center: { lat: 33.6844, lng: 73.0479 }, serviceRadiusKm: 25, operatingHours: { open: '00:00', close: '23:59' } },
  { id: 'rawalpindi', name: 'Rawalpindi', enabled: true, center: { lat: 33.5651, lng: 73.0169 }, serviceRadiusKm: 25, operatingHours: { open: '00:00', close: '23:59' } },
  { id: 'lahore', name: 'Lahore', enabled: false, center: { lat: 31.5497, lng: 74.3436 }, serviceRadiusKm: 25, operatingHours: { open: '00:00', close: '23:59' } },
  { id: 'karachi', name: 'Karachi', enabled: false, center: { lat: 24.8607, lng: 67.0011 }, serviceRadiusKm: 25, operatingHours: { open: '00:00', close: '23:59' } },
  { id: 'peshawar', name: 'Peshawar', enabled: false, center: { lat: 34.0151, lng: 71.5249 }, serviceRadiusKm: 20, operatingHours: { open: '00:00', close: '23:59' } },
  { id: 'faisalabad', name: 'Faisalabad', enabled: false, center: { lat: 31.4504, lng: 73.135 }, serviceRadiusKm: 20, operatingHours: { open: '00:00', close: '23:59' } },
  { id: 'multan', name: 'Multan', enabled: false, center: { lat: 30.1575, lng: 71.5249 }, serviceRadiusKm: 20, operatingHours: { open: '00:00', close: '23:59' } },
];

// Recognisable Islamabad / Rawalpindi localities used to scatter demo users realistically.
const LOCALITIES = [
  { label: 'F-7 Markaz, Islamabad', cityId: 'islamabad', lat: 33.7205, lng: 73.0498 },
  { label: 'Blue Area, Islamabad', cityId: 'islamabad', lat: 33.7089, lng: 73.0563 },
  { label: 'F-10 Markaz, Islamabad', cityId: 'islamabad', lat: 33.6938, lng: 73.0169 },
  { label: 'G-9 Markaz, Islamabad', cityId: 'islamabad', lat: 33.6884, lng: 73.0348 },
  { label: 'DHA Phase 2, Islamabad', cityId: 'islamabad', lat: 33.5417, lng: 73.1 },
  { label: 'Soan Gardens, Islamabad', cityId: 'islamabad', lat: 33.5833, lng: 73.0833 },
  { label: 'Saddar, Rawalpindi', cityId: 'rawalpindi', lat: 33.5989, lng: 73.0369 },
  { label: 'Committee Chowk, Rawalpindi', cityId: 'rawalpindi', lat: 33.6007, lng: 73.0433 },
  { label: 'Chaklala Scheme III, Rawalpindi', cityId: 'rawalpindi', lat: 33.5959, lng: 73.0783 },
  { label: 'Bahria Town Phase 4, Rawalpindi', cityId: 'rawalpindi', lat: 33.5333, lng: 73.15 },
  { label: 'PWD Housing, Islamabad', cityId: 'islamabad', lat: 33.5225, lng: 73.1408 },
  { label: 'Bahria Town Phase 8, Rawalpindi', cityId: 'rawalpindi', lat: 33.51, lng: 73.24 },
];

function jitter(rng, point, maxDeg = 0.006) {
  return {
    lat: point.lat + (rng() - 0.5) * 2 * maxDeg,
    lng: point.lng + (rng() - 0.5) * 2 * maxDeg,
  };
}

function buildPricingRules() {
  const rules = {};
  for (const city of CITIES) {
    for (const service of SERVICES) {
      const key = `${city.id}:${service.key}`;
      rules[key] = {
        cityId: city.id,
        serviceKey: service.key,
        nightStartHour: 21,
        nightEndHour: 5,
        ...DEFAULT_RULE_BY_SERVICE[service.key],
      };
    }
  }
  return rules;
}

function buildSeed() {
  const rng = createRng(19870512); // fixed seed -> identical demo data every restart
  const pricingRules = buildPricingRules();
  const now = new Date();

  const users = [];
  const customerProfiles = [];
  const helperProfiles = [];
  const vehicles = [];

  users.push({ id: 'admin_1', phone: '+923000000000', name: 'Madadgaar Admin', role: 'admin', photoUrl: null, createdAt: '2025-11-01T09:00:00.000Z' });

  // ---- Customers -------------------------------------------------------
  const aliLocation = { label: 'F-7 Markaz, Islamabad', ...LOCALITIES[0] };
  const customerSeeds = [
    { name: 'Ali Raza', phone: '+923001234567', locality: LOCALITIES[0] },
    { name: 'Sara Khan', phone: '+923012223344', locality: LOCALITIES[1] },
    { name: 'Bilal Ahmed', phone: '+923023334455', locality: LOCALITIES[2] },
    { name: 'Ayesha Malik', phone: '+923034445566', locality: LOCALITIES[3] },
    { name: 'Usman Tariq', phone: '+923045556677', locality: LOCALITIES[6] },
    { name: 'Hina Fatima', phone: '+923056667788', locality: LOCALITIES[7] },
    { name: 'Farhan Sheikh', phone: '+923067778899', locality: LOCALITIES[8] },
    { name: 'Zainab Iqbal', phone: '+923078889900', locality: LOCALITIES[4] },
    { name: 'Hassan Abbasi', phone: '+923089990011', locality: LOCALITIES[9] },
    { name: 'Mehwish Noor', phone: '+923090001122', locality: LOCALITIES[5] },
  ];
  customerSeeds.forEach((c, i) => {
    const id = i === 0 ? 'user_ali_demo' : `cust_${i}`;
    users.push({ id, phone: c.phone, name: c.name, role: 'customer', photoUrl: null, createdAt: `2025-1${intBetween(rng, 1, 2)}-0${intBetween(rng, 1, 9)}T10:00:00.000Z` });
    customerProfiles.push({ userId: id, savedLocations: [{ label: c.locality.label, lat: c.locality.lat, lng: c.locality.lng }], defaultVehicleId: null });
  });

  const vehicleSeeds = [
    { customerId: 'user_ali_demo', type: 'car', make: 'Honda', model: 'Civic', year: 2019, fuelType: 'petrol', nickname: 'My Honda Civic' },
    { customerId: 'cust_1', type: 'motorcycle', make: 'Honda', model: 'CG 125', year: 2021, fuelType: 'petrol', nickname: 'My Bike' },
    { customerId: 'cust_2', type: 'car', make: 'Suzuki', model: 'Alto', year: 2020, fuelType: 'petrol', nickname: null },
    { customerId: 'cust_4', type: 'car', make: 'Toyota', model: 'Corolla', year: 2018, fuelType: 'petrol', nickname: 'Papa ki Corolla' },
  ];
  vehicleSeeds.forEach((v, i) => {
    const id = `veh_${i + 1}`;
    vehicles.push({ id, ...v });
    const profile = customerProfiles.find((p) => p.userId === v.customerId);
    if (profile && !profile.defaultVehicleId) profile.defaultVehicleId = id;
  });

  // ---- Helpers -----------------------------------------------------------
  const helperSeeds = [
    { id: 'user_ahmed_demo', name: 'Ahmed Hussain', phone: '+923331234567', city: 'islamabad', vehicleType: 'motorcycle', vehicleMake: 'Honda', vehicleModel: 'CD 70', vehicleReg: 'ICT-4471', services: ['fuel', 'battery', 'tire'], experienceYears: 4, verificationStatus: 'verified', availability: 'online', rating: 4.9, completedJobs: 412, cancelledJobs: 6, memberSince: '2025-10-12', locality: LOCALITIES[0], nearAli: true, badges: ['identity_verified', 'vehicle_verified', 'highly_rated'] },
    { id: 'helper_2', name: 'Muhammad Ali', phone: '+923341234567', city: 'islamabad', vehicleType: 'motorcycle', vehicleMake: 'Honda', vehicleModel: 'CD 70', vehicleReg: 'ICT-2290', services: ['fuel', 'battery', 'tire'], experienceYears: 3, verificationStatus: 'verified', availability: 'online', rating: 4.8, completedJobs: 347, cancelledJobs: 9, memberSince: '2026-01-05', locality: LOCALITIES[3], badges: ['identity_verified', 'vehicle_verified', 'highly_rated'] },
    { id: 'helper_3', name: 'Bilal Sabir', phone: '+923351234567', city: 'rawalpindi', vehicleType: 'van', vehicleMake: 'Suzuki', vehicleModel: 'Ravi', vehicleReg: 'RWP-7712', services: ['towing', 'mechanic'], experienceYears: 6, verificationStatus: 'verified', availability: 'online', rating: 4.6, completedJobs: 210, cancelledJobs: 14, memberSince: '2025-09-20', locality: LOCALITIES[6], badges: ['identity_verified', 'vehicle_verified'] },
    { id: 'helper_4', name: 'Kamran Yousaf', phone: '+923361234567', city: 'islamabad', vehicleType: 'motorcycle', vehicleMake: 'Yamaha', vehicleModel: 'YBR 125', vehicleReg: 'ICT-8834', services: ['fuel', 'tire'], experienceYears: 2, verificationStatus: 'verified', availability: 'online', rating: 4.7, completedJobs: 156, cancelledJobs: 8, memberSince: '2026-02-14', locality: LOCALITIES[3], badges: ['identity_verified', 'vehicle_verified'] },
    { id: 'helper_5', name: 'Waqas Anjum', phone: '+923371234567', city: 'rawalpindi', vehicleType: 'truck', vehicleMake: 'Isuzu', vehicleModel: 'Pickup', vehicleReg: 'RWP-3345', services: ['towing'], experienceYears: 8, verificationStatus: 'verified', availability: 'offline', rating: 4.5, completedJobs: 98, cancelledJobs: 6, memberSince: '2025-08-02', locality: LOCALITIES[9], badges: ['identity_verified', 'vehicle_verified'] },
    { id: 'helper_6', name: 'Imran Sheikh', phone: '+923381234567', city: 'islamabad', vehicleType: 'motorcycle', vehicleMake: 'Honda', vehicleModel: 'CD 70', vehicleReg: 'ICT-5561', services: ['battery', 'tire', 'mechanic'], experienceYears: 5, verificationStatus: 'verified', availability: 'online', rating: 4.9, completedJobs: 289, cancelledJobs: 4, memberSince: '2025-07-18', locality: LOCALITIES[2], badges: ['identity_verified', 'vehicle_verified', 'highly_rated'] },
    { id: 'helper_7', name: 'Rabia Sultana', phone: '+923391234567', city: 'islamabad', vehicleType: 'car', vehicleMake: 'Suzuki', vehicleModel: 'Cultus', vehicleReg: 'ICT-9012', services: ['battery', 'mechanic'], experienceYears: 3, verificationStatus: 'verified', availability: 'offline', rating: 4.8, completedJobs: 134, cancelledJobs: 5, memberSince: '2026-01-22', locality: LOCALITIES[5], badges: ['identity_verified', 'vehicle_verified'] },
    { id: 'helper_8', name: 'Naveed Aslam', phone: '+923401234567', city: 'rawalpindi', vehicleType: 'motorcycle', vehicleMake: 'Honda', vehicleModel: 'CG 125', vehicleReg: 'RWP-6621', services: ['fuel'], experienceYears: 1, verificationStatus: 'pending', availability: 'offline', rating: 0, completedJobs: 0, cancelledJobs: 0, memberSince: '2026-09-02', locality: LOCALITIES[7], badges: [] },
    { id: 'helper_9', name: 'Adnan Malik', phone: '+923411234567', city: 'rawalpindi', vehicleType: 'motorcycle', vehicleMake: 'Honda', vehicleModel: 'CD 70', vehicleReg: 'RWP-1198', services: ['fuel', 'battery'], experienceYears: 2, verificationStatus: 'suspended', availability: 'offline', rating: 3.4, completedJobs: 41, cancelledJobs: 27, memberSince: '2025-12-30', locality: LOCALITIES[8], badges: [] },
    { id: 'helper_10', name: 'Shahid Raza', phone: '+923421234567', city: 'islamabad', vehicleType: 'car', vehicleMake: 'Suzuki', vehicleModel: 'Bolan', vehicleReg: 'ICT-3378', services: ['towing'], experienceYears: 1, verificationStatus: 'rejected', availability: 'offline', rating: 0, completedJobs: 0, cancelledJobs: 0, memberSince: '2026-08-20', locality: LOCALITIES[4], badges: [] },
  ];

  helperSeeds.forEach((h) => {
    users.push({ id: h.id, phone: h.phone, name: h.name, role: 'helper', photoUrl: null, createdAt: `${h.memberSince}T09:00:00.000Z` });
    const base = h.nearAli
      ? { lat: aliLocation.lat + 0.012, lng: aliLocation.lng + 0.013 }
      : jitter(rng, h.locality);
    helperProfiles.push({
      id: h.id,
      userId: h.id,
      name: h.name,
      phone: h.phone,
      photoUrl: null,
      city: h.city,
      vehicleType: h.vehicleType,
      vehicleMake: h.vehicleMake,
      vehicleModel: h.vehicleModel,
      vehicleReg: h.vehicleReg,
      servicesOffered: h.services,
      experienceYears: h.experienceYears,
      emergencyContact: '+923000000001',
      availability: h.availability,
      verificationStatus: h.verificationStatus,
      badges: h.badges,
      rating: h.rating,
      completedJobs: h.completedJobs,
      cancelledJobs: h.cancelledJobs,
      responseTimeMinAvg: h.completedJobs > 0 ? intBetween(rng, 2, 6) : null,
      memberSince: h.memberSince,
      currentLocation: base,
      activeRequestId: null,
      withdrawnTotalPaisa: 0,
    });
  });

  // ---- Historical requests (20 completed) --------------------------------
  const requests = [];
  const payments = [];
  const ratings = [];
  const messages = [];

  const verifiedHelpers = helperProfiles.filter((h) => h.verificationStatus === 'verified');
  const fuelTypes = ['petrol', 'diesel'];
  const quantities = [2, 5, 10];
  const paymentMethods = ['cod', 'easypaisa', 'jazzcash'];
  const reviewLines = [
    'Reached fast, very professional.',
    'Madadgaar hai na — sorted in minutes!',
    'Polite and quick, would request again.',
    'Fair price, no surprises.',
    'Helped me out late at night, thank you.',
    '',
    '',
  ];

  for (let i = 0; i < 20; i++) {
    const customer = pick(rng, customerProfiles);
    const service = pick(rng, SERVICES.filter((s) => s.key !== 'other'));
    const helperCandidates = verifiedHelpers.filter((h) => h.servicesOffered.includes(service.key));
    const helper = helperCandidates.length ? pick(rng, helperCandidates) : pick(rng, verifiedHelpers);
    const rule = pricingRules[`${helper.city}:${service.key}`];
    const pickup = jitter(rng, helperProfiles.find((h) => h.id === helper.id).currentLocation, 0.02);
    const distKm = Math.max(0.3, distanceKm(helper.currentLocation, pickup));

    // Spread over the last 14 days, weighted so several land "today" (for non-zero live dashboard numbers).
    const daysAgo = i < 5 ? 0 : intBetween(rng, 0, 13);
    const createdAt = new Date(now);
    createdAt.setDate(createdAt.getDate() - daysAgo);
    createdAt.setHours(intBetween(rng, 7, 23), intBetween(rng, 0, 59), 0, 0);

    const details = service.key === 'fuel' ? { fuelType: pick(rng, fuelTypes), quantityLitres: pick(rng, quantities) } : {};
    const priced = estimatePrice({ rule, serviceKey: service.key, details, distanceKm: distKm, now: createdAt });

    const acceptedAt = new Date(createdAt.getTime() + intBetween(rng, 1, 3) * 60000);
    const arrivedAt = new Date(acceptedAt.getTime() + intBetween(rng, 4, 12) * 60000);
    const startedAt = new Date(arrivedAt.getTime() + intBetween(rng, 1, 3) * 60000);
    const completedAt = new Date(startedAt.getTime() + intBetween(rng, 5, 15) * 60000);

    const reqId = `req_hist_${i + 1}`;
    requests.push({
      id: reqId,
      customerId: customer.userId,
      helperId: helper.id,
      serviceKey: service.key,
      details,
      cityId: helper.city,
      pickupLocation: { ...pickup, address: LOCALITIES.find((l) => l.cityId === helper.city)?.label ?? helper.city },
      status: 'COMPLETED',
      pricing: priced,
      distanceKm: Number(distKm.toFixed(2)),
      createdAt: createdAt.toISOString(),
      acceptedAt: acceptedAt.toISOString(),
      arrivedAt: arrivedAt.toISOString(),
      startedAt: startedAt.toISOString(),
      completedAt: completedAt.toISOString(),
      cancelledAt: null,
      cancelReason: null,
      cancelledBy: null,
      matching: { radiusRoundIndex: 0, offeredHelperIds: [helper.id], declinedHelperIds: [] },
    });

    const method = pick(rng, paymentMethods);
    payments.push({
      id: `pay_${i + 1}`,
      requestId: reqId,
      method,
      status: 'paid',
      amount: priced.breakdown.total,
      simulated: true,
      createdAt: completedAt.toISOString(),
      paidAt: completedAt.toISOString(),
    });

    const stars = intBetween(rng, 4, 5);
    ratings.push({
      id: `rating_${i + 1}`,
      requestId: reqId,
      fromUserId: customer.userId,
      toUserId: helper.id,
      direction: 'customer_to_helper',
      stars,
      review: pick(rng, reviewLines),
      createdAt: completedAt.toISOString(),
    });
  }

  // ---- A few live/active requests (not involving Ali/Ahmed, so the judge's
  // own demo run starts clean) --------------------------------------------
  const activeSeeds = [
    { customerIdx: 3, service: 'battery', helperId: 'helper_6', status: 'HELPER_ON_THE_WAY' },
    { customerIdx: 5, service: 'tire', helperId: 'helper_4', status: 'ARRIVED' },
    { customerIdx: 7, service: 'towing', helperId: 'helper_3', status: 'ACCEPTED' },
  ];
  activeSeeds.forEach((a, i) => {
    const customer = customerProfiles[a.customerIdx];
    const helper = helperProfiles.find((h) => h.id === a.helperId);
    const rule = pricingRules[`${helper.city}:${a.service}`];
    const pickup = jitter(rng, helper.currentLocation, 0.015);
    const distKm = Math.max(0.3, distanceKm(helper.currentLocation, pickup));
    const details = a.service === 'fuel' ? { fuelType: 'petrol', quantityLitres: 5 } : {};
    const priced = estimatePrice({ rule, serviceKey: a.service, details, distanceKm: distKm, now });
    const createdAt = new Date(now.getTime() - intBetween(rng, 4, 9) * 60000);

    const reqId = `req_active_${i + 1}`;
    requests.push({
      id: reqId,
      customerId: customer.userId,
      helperId: helper.id,
      serviceKey: a.service,
      details,
      cityId: helper.city,
      pickupLocation: { ...pickup, address: LOCALITIES.find((l) => l.cityId === helper.city)?.label ?? helper.city },
      status: a.status,
      pricing: priced,
      distanceKm: Number(distKm.toFixed(2)),
      createdAt: createdAt.toISOString(),
      acceptedAt: createdAt.toISOString(),
      arrivedAt: a.status === 'ARRIVED' ? new Date().toISOString() : null,
      startedAt: null,
      completedAt: null,
      cancelledAt: null,
      cancelReason: null,
      cancelledBy: null,
      matching: { radiusRoundIndex: 0, offeredHelperIds: [helper.id], declinedHelperIds: [] },
    });
    helper.activeRequestId = reqId;
  });

  return {
    cities: CITIES,
    services: SERVICES,
    pricingRules,
    matchingConfig: {
      weights: { distance: 0.35, service: 0.15, availability: 0.1, rating: 0.25, reliability: 0.15 },
      radiusRoundsKm: [2, 5, 10],
      offerTimeoutSeconds: 15,
    },
    users,
    customerProfiles,
    helperProfiles,
    vehicles,
    requests,
    payments,
    ratings,
    messages,
    notifications: [],
    disputes: [],
  };
}

module.exports = { buildSeed, SERVICES, CITIES, DEFAULT_RULE_BY_SERVICE, LOCALITIES };
