const { buildSeed } = require('./seed');

/**
 * Single in-memory source of truth for the whole demo. Every one of the
 * three Flutter apps (customer, helper, admin) talks to the same running
 * instance of this server, so state genuinely stays in sync across all
 * three windows during a live demo — nothing is faked client-side.
 *
 * Resets to the seeded demo data on every server restart.
 */
const db = buildSeed();

function findById(list, id) {
  return list.find((item) => item.id === id) ?? null;
}

const store = {
  db,

  // ---- users / profiles -------------------------------------------------
  getUser(id) {
    return findById(db.users, id);
  },
  getUserByPhone(phone) {
    return db.users.find((u) => u.phone === phone) ?? null;
  },
  createUser(user) {
    db.users.push(user);
    return user;
  },
  getCustomerProfile(userId) {
    return db.customerProfiles.find((c) => c.userId === userId) ?? null;
  },
  getOrCreateCustomerProfile(userId) {
    let profile = store.getCustomerProfile(userId);
    if (!profile) {
      profile = { userId, savedLocations: [], defaultVehicleId: null };
      db.customerProfiles.push(profile);
    }
    return profile;
  },
  getHelperProfile(id) {
    return findById(db.helperProfiles, id);
  },
  listHelperProfiles(filter = {}) {
    return db.helperProfiles.filter((h) => {
      if (filter.city && h.city !== filter.city) return false;
      if (filter.verificationStatus && h.verificationStatus !== filter.verificationStatus) return false;
      return true;
    });
  },
  createHelperProfile(profile) {
    db.helperProfiles.push(profile);
    return profile;
  },

  // ---- vehicles -----------------------------------------------------------
  listVehicles(customerId) {
    return db.vehicles.filter((v) => v.customerId === customerId);
  },
  addVehicle(vehicle) {
    db.vehicles.push(vehicle);
    return vehicle;
  },
  removeVehicle(id) {
    const idx = db.vehicles.findIndex((v) => v.id === id);
    if (idx >= 0) db.vehicles.splice(idx, 1);
  },

  // ---- cities / services / pricing ----------------------------------------
  listCities() {
    return db.cities;
  },
  getCity(id) {
    return findById(db.cities, id);
  },
  listServices() {
    return db.services;
  },
  getPricingRule(cityId, serviceKey) {
    return db.pricingRules[`${cityId}:${serviceKey}`] ?? null;
  },
  updatePricingRule(cityId, serviceKey, patch) {
    const key = `${cityId}:${serviceKey}`;
    const current = db.pricingRules[key];
    if (!current) return null;
    db.pricingRules[key] = { ...current, ...patch };
    return db.pricingRules[key];
  },

  // ---- requests -------------------------------------------------------------
  getRequest(id) {
    return findById(db.requests, id);
  },
  listRequests(filter = {}) {
    return db.requests.filter((r) => {
      if (filter.customerId && r.customerId !== filter.customerId) return false;
      if (filter.helperId && r.helperId !== filter.helperId) return false;
      if (filter.status === 'active') return !['COMPLETED', 'CANCELLED'].includes(r.status);
      if (filter.status && r.status !== filter.status) return false;
      return true;
    });
  },
  createRequest(request) {
    db.requests.push(request);
    return request;
  },

  // ---- payments / ratings / messages / notifications / disputes ------------
  createPayment(payment) {
    db.payments.push(payment);
    return payment;
  },
  getPaymentByRequest(requestId) {
    return db.payments.find((p) => p.requestId === requestId) ?? null;
  },
  createRating(rating) {
    db.ratings.push(rating);
    return rating;
  },
  listRatingsFor(userId) {
    return db.ratings.filter((r) => r.toUserId === userId);
  },
  listMessages(requestId) {
    return db.messages.filter((m) => m.requestId === requestId);
  },
  addMessage(message) {
    db.messages.push(message);
    return message;
  },
  addNotification(notification) {
    db.notifications.push(notification);
    return notification;
  },
  listNotifications(userId) {
    return db.notifications
      .filter((n) => n.userId === userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  },
  createDispute(dispute) {
    db.disputes.push(dispute);
    return dispute;
  },
  listDisputes() {
    return db.disputes;
  },
};

module.exports = { store };
