const { store } = require('./store');
const { broadcast } = require('./ws');
const { rankCandidates } = require('./matching');
const { distanceKm, etaMinutes, lerpPoint } = require('./lib/geo');
const { id } = require('./lib/id');

const offerTimers = new Map(); // requestId -> Timeout
const locationTickers = new Map(); // requestId -> Interval

const ACTIVE_STATUSES = ['SEARCHING', 'ACCEPTED', 'HELPER_ON_THE_WAY', 'ARRIVED', 'SERVICE_STARTED'];

function helperPreview(helper, distKm) {
  return {
    helperId: helper.id,
    name: helper.name,
    rating: helper.rating,
    completedJobs: helper.completedJobs,
    vehicleType: helper.vehicleType,
    vehicleMake: helper.vehicleMake,
    vehicleModel: helper.vehicleModel,
    badges: helper.badges,
    verified: helper.verificationStatus === 'verified',
    photoUrl: helper.photoUrl,
    distanceKm: Number(distKm.toFixed(2)),
    etaMinutes: etaMinutes(distKm),
  };
}

function notify(userId, title, body, data = {}) {
  const n = store.addNotification({
    id: id('notif'),
    userId,
    title,
    body,
    data,
    read: false,
    createdAt: new Date().toISOString(),
  });
  broadcast('notification.created', n);
}

function pickNextCandidate(request) {
  const config = store.db.matchingConfig;
  for (let i = request.matching.radiusRoundIndex; i < config.radiusRoundsKm.length; i++) {
    const radiusKm = config.radiusRoundsKm[i];
    const candidates = rankCandidates(store.db.helperProfiles, request, radiusKm, config.weights).filter(
      (c) => !request.matching.declinedHelperIds.includes(c.helper.id)
    );
    if (candidates.length) {
      request.matching.radiusRoundIndex = i;
      return candidates[0];
    }
  }
  return null;
}

function clearOfferTimer(requestId) {
  const t = offerTimers.get(requestId);
  if (t) {
    clearTimeout(t);
    offerTimers.delete(requestId);
  }
}

function offerNext(requestId) {
  const request = store.getRequest(requestId);
  if (!request || request.status !== 'SEARCHING') return;

  const candidate = pickNextCandidate(request);
  if (!candidate) {
    broadcast('request.no_helpers_available', { requestId });
    return;
  }

  request.matching.offeredHelperIds.push(candidate.helper.id);
  request.matching.currentOfferHelperId = candidate.helper.id;

  broadcast('request.candidate_offered', { requestId, ...helperPreview(candidate.helper, candidate.distanceKm) });
  notify(candidate.helper.id, 'New assistance request nearby', `${request.serviceKey} request ~${candidate.distanceKm.toFixed(1)}km away`, { requestId });

  const config = store.db.matchingConfig;
  clearOfferTimer(requestId);
  const timer = setTimeout(() => {
    const current = store.getRequest(requestId);
    if (current && current.status === 'SEARCHING' && current.matching.currentOfferHelperId === candidate.helper.id) {
      current.matching.declinedHelperIds.push(candidate.helper.id);
      current.matching.currentOfferHelperId = null;
      offerNext(requestId);
    }
  }, config.offerTimeoutSeconds * 1000);
  offerTimers.set(requestId, timer);
}

/** Kicks off (or restarts) the broadcast/expand-radius search for a SEARCHING request. */
function startDispatch(requestId) {
  offerNext(requestId);
}

function declineOffer(requestId, helperId) {
  const request = store.getRequest(requestId);
  if (!request || request.matching.currentOfferHelperId !== helperId) return;
  clearOfferTimer(requestId);
  request.matching.declinedHelperIds.push(helperId);
  request.matching.currentOfferHelperId = null;
  offerNext(requestId);
}

function stopLocationTicker(requestId) {
  const t = locationTickers.get(requestId);
  if (t) {
    clearInterval(t);
    locationTickers.delete(requestId);
  }
}

function startLocationTicker(requestId) {
  const request = store.getRequest(requestId);
  const helper = store.getHelperProfile(request.helperId);
  if (!request || !helper) return;

  const origin = { ...helper.currentLocation };
  const target = request.pickupLocation;
  const totalTicks = 15;
  let tick = 0;

  stopLocationTicker(requestId);
  const timer = setInterval(() => {
    tick += 1;
    const current = store.getRequest(requestId);
    if (!current || !ACTIVE_STATUSES.includes(current.status) || tick >= totalTicks) {
      if (current && ['ARRIVED', 'SERVICE_STARTED', 'COMPLETED'].includes(current.status)) {
        helper.currentLocation = { ...target };
      }
      stopLocationTicker(requestId);
      return;
    }
    const newLocation = lerpPoint(origin, target, tick / totalTicks);
    helper.currentLocation = newLocation;
    const remainingKm = distanceKm(newLocation, target);
    broadcast('helper.location_update', {
      requestId,
      helperId: helper.id,
      location: newLocation,
      distanceKm: Number(remainingKm.toFixed(2)),
      etaMinutes: etaMinutes(remainingKm),
    });
  }, 2000);
  locationTickers.set(requestId, timer);
}

module.exports = {
  startDispatch,
  declineOffer,
  clearOfferTimer,
  startLocationTicker,
  stopLocationTicker,
  helperPreview,
  notify,
};
