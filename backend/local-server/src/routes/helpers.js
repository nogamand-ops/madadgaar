const express = require('express');
const { store } = require('../store');
const { id } = require('../lib/id');
const { broadcast } = require('../ws');
const { notify } = require('../dispatch');
const { computeHelperEarnings } = require('../earnings');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', (req, res) => {
  const { city, service, verificationStatus } = req.query;
  let list = store.listHelperProfiles({ city, verificationStatus });
  if (service) list = list.filter((h) => h.servicesOffered.includes(service));
  res.json(list);
});

router.get('/:id', (req, res) => {
  const helper = store.getHelperProfile(req.params.id);
  if (!helper) return res.status(404).json({ error: 'not found' });
  res.json(helper);
});

router.get('/:id/earnings', (req, res) => {
  const helper = store.getHelperProfile(req.params.id);
  if (!helper) return res.status(404).json({ error: 'not found' });
  res.json(computeHelperEarnings(req.params.id));
});

// "Become a Madadgaar" — supply-side registration.
router.post('/', requireAuth, (req, res) => {
  const b = req.body || {};
  const required = ['name', 'city', 'vehicleType', 'servicesOffered'];
  for (const field of required) {
    if (!b[field]) return res.status(400).json({ error: `${field} is required` });
  }
  const city = store.getCity(b.city);
  if (!city) return res.status(400).json({ error: 'unknown city' });

  const helperId = req.user.id; // the logged-in user becomes the helper
  if (store.getHelperProfile(helperId)) {
    return res.status(409).json({ error: 'helper profile already exists for this account' });
  }

  const profile = store.createHelperProfile({
    id: helperId,
    userId: helperId,
    name: b.name,
    phone: req.user.phone,
    photoUrl: null,
    city: b.city,
    vehicleType: b.vehicleType,
    vehicleMake: b.vehicleMake || null,
    vehicleModel: b.vehicleModel || null,
    vehicleReg: b.vehicleReg || null,
    servicesOffered: b.servicesOffered,
    experienceYears: Number(b.experienceYears) || 0,
    emergencyContact: b.emergencyContact || null,
    availability: 'offline',
    verificationStatus: 'pending',
    badges: [],
    rating: 0,
    completedJobs: 0,
    cancelledJobs: 0,
    responseTimeMinAvg: null,
    memberSince: new Date().toISOString().slice(0, 10),
    currentLocation: city.center,
    activeRequestId: null,
    withdrawnTotalPaisa: 0,
  });

  notify('admin_1', 'New helper verification submitted', `${profile.name} applied to become a Madadgaar in ${city.name}.`, { helperId });
  broadcast('helper.updated', profile);
  res.status(201).json(profile);
});

// Helper self-updates: go online/offline, live GPS ping, edit services.
router.patch('/:id', requireAuth, (req, res) => {
  const helper = store.getHelperProfile(req.params.id);
  if (!helper) return res.status(404).json({ error: 'not found' });
  if (req.user.id !== helper.id && req.user.role !== 'admin') return res.status(403).json({ error: 'forbidden' });

  const { availability, currentLocation, servicesOffered, experienceYears, vehicleType, vehicleMake, vehicleModel, vehicleReg } = req.body || {};
  if (availability && ['online', 'offline'].includes(availability)) helper.availability = availability;
  if (currentLocation?.lat != null && currentLocation?.lng != null) helper.currentLocation = { lat: currentLocation.lat, lng: currentLocation.lng };
  if (Array.isArray(servicesOffered)) helper.servicesOffered = servicesOffered;
  if (experienceYears != null) helper.experienceYears = Number(experienceYears);
  if (vehicleType) helper.vehicleType = vehicleType;
  if (vehicleMake) helper.vehicleMake = vehicleMake;
  if (vehicleModel) helper.vehicleModel = vehicleModel;
  if (vehicleReg) helper.vehicleReg = vehicleReg;

  broadcast('helper.updated', helper);
  res.json(helper);
});

// Admin-only: approve / reject / suspend.
router.patch('/:id/verification', requireAuth, requireRole('admin'), (req, res) => {
  const helper = store.getHelperProfile(req.params.id);
  if (!helper) return res.status(404).json({ error: 'not found' });
  const { status } = req.body || {};
  if (!['pending', 'verified', 'rejected', 'suspended'].includes(status)) {
    return res.status(400).json({ error: 'invalid status' });
  }
  helper.verificationStatus = status;
  helper.badges = status === 'verified' ? Array.from(new Set([...(helper.badges || []), 'identity_verified', 'vehicle_verified'])) : helper.badges;
  if (status !== 'verified') helper.availability = 'offline';

  broadcast('helper.updated', helper);
  notify(helper.userId, `Verification ${status}`, `Your Madadgaar application status is now "${status}".`, { status });
  res.json(helper);
});

router.post('/:id/withdraw', requireAuth, (req, res) => {
  const helper = store.getHelperProfile(req.params.id);
  if (!helper) return res.status(404).json({ error: 'not found' });
  if (req.user.id !== helper.id) return res.status(403).json({ error: 'forbidden' });

  const { amount } = req.body || {};
  const earnings = computeHelperEarnings(helper.id);
  const amt = Number(amount);
  if (!amt || amt <= 0 || amt > earnings.availableBalance) {
    return res.status(400).json({ error: 'invalid withdrawal amount' });
  }
  helper.withdrawnTotalPaisa = (helper.withdrawnTotalPaisa || 0) + amt;
  const updated = computeHelperEarnings(helper.id);
  res.json({ withdrawn: amt, simulated: true, ...updated });
});

module.exports = router;
