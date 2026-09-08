const { distanceKm: haversineKm } = require('./lib/geo');

const DEFAULT_WEIGHTS = {
  distance: 0.35,
  service: 0.15,
  availability: 0.1,
  rating: 0.25,
  reliability: 0.15,
};

const DEFAULT_RADIUS_ROUNDS_KM = [2, 5, 10];

function reliabilityScore(helper) {
  const completed = helper.completedJobs ?? 0;
  const cancelled = helper.cancelledJobs ?? 0;
  // Laplace-smoothed acceptance/completion rate so a brand-new helper isn't 0.
  return (completed + 1) / (completed + cancelled + 2);
}

function isEligible(helper, request) {
  return (
    helper.verificationStatus === 'verified' &&
    helper.availability === 'online' &&
    (helper.activeRequestId == null) &&
    Array.isArray(helper.servicesOffered) &&
    helper.servicesOffered.includes(request.serviceKey)
  );
}

function scoreHelper(helper, distKm, radiusKm, weights) {
  const distanceScore = Math.max(0, 1 - distKm / radiusKm);
  const serviceScore = 1; // already filtered to capable helpers
  const availabilityScore = 1; // already filtered to online + free helpers
  const ratingScore = (helper.rating ?? 4.5) / 5;
  const reliability = reliabilityScore(helper);

  return (
    weights.distance * distanceScore +
    weights.service * serviceScore +
    weights.availability * availabilityScore +
    weights.rating * ratingScore +
    weights.reliability * reliability
  );
}

/**
 * Ranks online, verified, capable helpers within `radiusKm` of the request's
 * pickup location, best match first. Returns [] if nobody qualifies in this
 * radius round — the caller should then retry with the next (larger) round.
 */
function rankCandidates(helpers, request, radiusKm, weights = DEFAULT_WEIGHTS) {
  return helpers
    .filter((h) => isEligible(h, request))
    .map((h) => {
      const distKm = haversineKm(h.currentLocation, request.pickupLocation);
      return { helper: h, distanceKm: distKm };
    })
    .filter((c) => c.distanceKm <= radiusKm)
    .map((c) => ({ ...c, score: scoreHelper(c.helper, c.distanceKm, radiusKm, weights) }))
    .sort((a, b) => b.score - a.score);
}

module.exports = {
  DEFAULT_WEIGHTS,
  DEFAULT_RADIUS_ROUNDS_KM,
  rankCandidates,
  reliabilityScore,
  isEligible,
};
