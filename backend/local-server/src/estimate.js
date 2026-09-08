const { store } = require('./store');
const { estimatePrice } = require('./pricing');
const { distanceKm } = require('./lib/geo');
const { isEligible } = require('./matching');

/**
 * Distance fee is based on how far the closest currently-available helper
 * would have to travel. If nobody is online right now we still owe the
 * customer an honest estimate, so we fall back to a conservative assumed
 * distance rather than blocking the price screen.
 */
function nearestEligibleDistanceKm(cityId, serviceKey, location) {
  const probe = { serviceKey };
  const eligible = store.db.helperProfiles.filter((h) => h.city === cityId && isEligible(h, probe));
  if (!eligible.length) return 3;
  return Math.min(...eligible.map((h) => distanceKm(h.currentLocation, location)));
}

function computeEstimate({ cityId, serviceKey, details, location, now = new Date() }) {
  const rule = store.getPricingRule(cityId, serviceKey);
  if (!rule) throw new Error(`No pricing rule configured for ${cityId}/${serviceKey}`);
  const distKm = nearestEligibleDistanceKm(cityId, serviceKey, location);
  const priced = estimatePrice({ rule, serviceKey, details, distanceKm: distKm, now });
  return { distanceKm: Number(distKm.toFixed(2)), ...priced };
}

module.exports = { computeEstimate, nearestEligibleDistanceKm };
