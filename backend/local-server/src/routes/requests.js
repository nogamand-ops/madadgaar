const express = require('express');
const { store } = require('../store');
const { id } = require('../lib/id');
const { broadcast } = require('../ws');
const { computeEstimate } = require('../estimate');
const { startDispatch, declineOffer, startLocationTicker, stopLocationTicker, notify, clearOfferTimer } = require('../dispatch');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

const FORWARD_TRANSITIONS = {
  HELPER_ON_THE_WAY: ['ARRIVED'],
  ARRIVED: ['SERVICE_STARTED'],
  SERVICE_STARTED: ['COMPLETED'],
};
const CANCELLABLE_STATUSES = ['SEARCHING', 'HELPER_ON_THE_WAY', 'ARRIVED', 'SERVICE_STARTED'];

function publicRequest(r) {
  return r; // demo scope: no field redaction needed beyond what's already role-scoped by route guards
}

router.get('/', requireAuth, (req, res) => {
  const { customerId, helperId, status, cityId } = req.query;
  if (req.user.role !== 'admin') {
    const self = req.user.id;
    if (customerId && customerId !== self) return res.status(403).json({ error: 'forbidden' });
    if (helperId && helperId !== self) return res.status(403).json({ error: 'forbidden' });
    if (!customerId && !helperId) return res.status(403).json({ error: 'customerId or helperId is required' });
  }
  let list = store.listRequests({ customerId, helperId, status });
  if (cityId) list = list.filter((r) => r.cityId === cityId);
  res.json(list.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).map(publicRequest));
});

router.get('/:id', requireAuth, (req, res) => {
  const r = store.getRequest(req.params.id);
  if (!r) return res.status(404).json({ error: 'not found' });
  res.json(publicRequest(r));
});

router.post('/', requireAuth, requireRole('customer'), (req, res) => {
  const { serviceKey, details, location, cityId, clientRequestId } = req.body || {};
  if (!serviceKey || !location?.lat || !location?.lng || !cityId) {
    return res.status(400).json({ error: 'serviceKey, location and cityId are required' });
  }
  const city = store.getCity(cityId);
  if (!city || !city.enabled) return res.status(400).json({ error: 'Madadgaar is not yet available in this city.' });
  const service = store.db.services.find((s) => s.key === serviceKey && s.active);
  if (!service) return res.status(400).json({ error: 'unknown or unavailable service' });

  // Idempotency: never create a second order for the same client-side attempt,
  // and disallow a second concurrent request from the same customer.
  const existingActive = store.listRequests({ customerId: req.user.id, status: 'active' })[0];
  if (existingActive) {
    if (clientRequestId && existingActive.clientRequestId === clientRequestId) {
      return res.status(200).json(existingActive);
    }
    return res.status(409).json({ error: 'You already have an active request in progress.', requestId: existingActive.id });
  }

  let priced;
  try {
    priced = computeEstimate({ cityId, serviceKey, details, location });
  } catch (e) {
    return res.status(400).json({ error: e.message });
  }

  const now = new Date();
  const request = store.createRequest({
    id: id('req'),
    clientRequestId: clientRequestId || null,
    customerId: req.user.id,
    helperId: null,
    serviceKey,
    details: details || {},
    cityId,
    pickupLocation: location,
    status: 'REQUESTED',
    pricing: { breakdown: priced.breakdown, revenue: priced.revenue, isNight: priced.isNight },
    distanceKm: priced.distanceKm,
    createdAt: now.toISOString(),
    acceptedAt: null,
    arrivedAt: null,
    startedAt: null,
    completedAt: null,
    cancelledAt: null,
    cancelReason: null,
    cancelledBy: null,
    matching: { radiusRoundIndex: 0, offeredHelperIds: [], declinedHelperIds: [], currentOfferHelperId: null },
  });
  broadcast('request.created', request);

  request.status = 'SEARCHING';
  broadcast('request.status_changed', request);
  // Give the client a moment to receive this response and subscribe to
  // this request's live updates before the first candidate offer
  // broadcasts — otherwise a fast server can broadcast it before the app
  // has navigated to the searching screen, and the app would silently
  // miss it (WebSocket broadcasts aren't replayed to late subscribers).
  // This also paces the "Finding a Madadgaar nearby…" moment naturally.
  setTimeout(() => startDispatch(request.id), 1500);

  res.status(201).json(request);
});

router.post('/:id/accept', requireAuth, requireRole('helper'), (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  if (request.status !== 'SEARCHING' || request.matching.currentOfferHelperId !== req.user.id) {
    return res.status(409).json({ error: 'This request is no longer available to you.' });
  }
  const helper = store.getHelperProfile(req.user.id);
  clearOfferTimer(request.id);

  request.helperId = helper.id;
  request.status = 'HELPER_ON_THE_WAY';
  request.acceptedAt = new Date().toISOString();
  request.matching.currentOfferHelperId = null;
  helper.activeRequestId = request.id;

  broadcast('request.status_changed', request);
  notify(request.customerId, 'Your Madadgaar is on the way', `${helper.name} accepted your request and is heading over.`, { requestId: request.id });
  startLocationTicker(request.id);

  res.json(request);
});

router.post('/:id/decline', requireAuth, requireRole('helper'), (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  declineOffer(request.id, req.user.id);
  res.json({ ok: true });
});

router.post('/:id/retry-search', requireAuth, requireRole('customer'), (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request || request.customerId !== req.user.id) return res.status(404).json({ error: 'not found' });
  if (request.status !== 'SEARCHING') return res.status(409).json({ error: 'request is not searching' });
  request.matching = { radiusRoundIndex: 0, offeredHelperIds: [], declinedHelperIds: [], currentOfferHelperId: null };
  startDispatch(request.id);
  res.json(request);
});

router.patch('/:id/status', requireAuth, requireRole('helper'), (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  if (request.helperId !== req.user.id) return res.status(403).json({ error: 'forbidden' });

  const { status } = req.body || {};
  const allowed = FORWARD_TRANSITIONS[request.status] || [];
  if (!allowed.includes(status)) {
    return res.status(409).json({ error: `Cannot move from ${request.status} to ${status}` });
  }

  request.status = status;
  const now = new Date().toISOString();
  if (status === 'ARRIVED') request.arrivedAt = now;
  if (status === 'SERVICE_STARTED') request.startedAt = now;
  if (status === 'COMPLETED') {
    request.completedAt = now;
    const helper = store.getHelperProfile(request.helperId);
    helper.completedJobs += 1;
    helper.activeRequestId = null;
    notify(request.customerId, 'Request completed', 'Your Madadgaar has completed the job. Please rate your experience.', { requestId: request.id });
  }
  if (status === 'ARRIVED') notify(request.customerId, 'Your helper has arrived', 'Your Madadgaar has arrived at your location.', { requestId: request.id });

  broadcast('request.status_changed', request);
  if (status === 'ARRIVED') stopLocationTicker(request.id);
  res.json(request);
});

router.post('/:id/cancel', requireAuth, (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  const isCustomer = request.customerId === req.user.id;
  const isHelper = request.helperId === req.user.id;
  if (!isCustomer && !isHelper && req.user.role !== 'admin') return res.status(403).json({ error: 'forbidden' });
  if (!CANCELLABLE_STATUSES.includes(request.status)) {
    return res.status(409).json({ error: 'This request can no longer be cancelled.' });
  }

  const { reason, cancelledBy } = req.body || {};
  const rule = store.getPricingRule(request.cityId, request.serviceKey);
  const wasCommitted = ['HELPER_ON_THE_WAY', 'ARRIVED', 'SERVICE_STARTED'].includes(request.status);
  const feeCharged = wasCommitted && cancelledBy === 'customer' ? rule?.cancellationFeeFlat ?? 0 : 0;

  request.status = 'CANCELLED';
  request.cancelledAt = new Date().toISOString();
  request.cancelReason = reason || 'Other';
  request.cancelledBy = cancelledBy || (isCustomer ? 'customer' : 'helper');
  request.cancellationFeeCharged = feeCharged;

  clearOfferTimer(request.id);
  stopLocationTicker(request.id);
  if (request.helperId) {
    const helper = store.getHelperProfile(request.helperId);
    if (helper) {
      helper.activeRequestId = null;
      if (request.cancelledBy === 'helper') helper.cancelledJobs += 1;
    }
  }

  broadcast('request.status_changed', request);
  const otherPartyId = isCustomer ? request.helperId : request.customerId;
  if (otherPartyId) notify(otherPartyId, 'Request cancelled', `The ${isCustomer ? 'customer' : 'helper'} cancelled this request.`, { requestId: request.id });

  res.json(request);
});

// ---- chat -----------------------------------------------------------------
router.get('/:id/messages', requireAuth, (req, res) => {
  res.json(store.listMessages(req.params.id));
});

router.post('/:id/messages', requireAuth, (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  const { text, isQuickMessage } = req.body || {};
  if (!text || !text.trim()) return res.status(400).json({ error: 'text is required' });

  const message = store.addMessage({
    id: id('msg'),
    requestId: request.id,
    senderId: req.user.id,
    text: text.trim().slice(0, 500),
    isQuickMessage: Boolean(isQuickMessage),
    createdAt: new Date().toISOString(),
  });
  broadcast('chat.message', message);
  res.status(201).json(message);
});

// ---- rating -----------------------------------------------------------------
router.post('/:id/rating', requireAuth, (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  if (request.status !== 'COMPLETED') return res.status(409).json({ error: 'request is not completed yet' });

  const { toUserId, stars, review } = req.body || {};
  const s = Number(stars);
  if (!toUserId || s < 1 || s > 5) return res.status(400).json({ error: 'toUserId and stars (1-5) are required' });

  const direction = toUserId === request.helperId ? 'customer_to_helper' : 'helper_to_customer';
  const rating = store.createRating({
    id: id('rating'),
    requestId: request.id,
    fromUserId: req.user.id,
    toUserId,
    direction,
    stars: s,
    review: review || '',
    createdAt: new Date().toISOString(),
  });

  if (direction === 'customer_to_helper') {
    const helper = store.getHelperProfile(toUserId);
    if (helper) {
      const all = store.listRatingsFor(toUserId).filter((r) => r.direction === 'customer_to_helper');
      helper.rating = Number((all.reduce((sum, r) => sum + r.stars, 0) / all.length).toFixed(1));
      if (helper.completedJobs >= 100 && helper.rating >= 4.7 && !helper.badges.includes('highly_rated')) {
        helper.badges = [...helper.badges, 'highly_rated'];
      }
      broadcast('helper.updated', helper);
    }
  }

  broadcast('rating.created', rating);
  res.status(201).json(rating);
});

// ---- payment -----------------------------------------------------------------
router.post('/:id/payment', requireAuth, (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });

  const existing = store.getPaymentByRequest(request.id);
  if (existing) return res.status(200).json(existing); // idempotent: never double-charge on retry

  const { method } = req.body || {};
  if (!['cod', 'easypaisa', 'jazzcash'].includes(method)) return res.status(400).json({ error: 'invalid payment method' });

  const now = new Date().toISOString();
  const payment = store.createPayment({
    id: id('pay'),
    requestId: request.id,
    method,
    status: method === 'cod' ? 'pending' : 'paid',
    amount: request.pricing.breakdown.total,
    simulated: true,
    createdAt: now,
    paidAt: method === 'cod' ? null : now,
  });
  broadcast('payment.updated', payment);
  res.status(201).json(payment);
});

router.get('/:id/payment', requireAuth, (req, res) => {
  const payment = store.getPaymentByRequest(req.params.id);
  if (!payment) return res.status(404).json({ error: 'not found' });
  res.json(payment);
});

router.post('/:id/payment/mark-collected', requireAuth, (req, res) => {
  const payment = store.getPaymentByRequest(req.params.id);
  if (!payment || payment.method !== 'cod') return res.status(404).json({ error: 'not found' });
  payment.status = 'paid';
  payment.paidAt = new Date().toISOString();
  broadcast('payment.updated', payment);
  res.json(payment);
});

// ---- disputes -----------------------------------------------------------------
router.post('/:id/disputes', requireAuth, (req, res) => {
  const request = store.getRequest(req.params.id);
  if (!request) return res.status(404).json({ error: 'not found' });
  const { reason } = req.body || {};
  if (!reason) return res.status(400).json({ error: 'reason is required' });

  const dispute = store.createDispute({
    id: id('dispute'),
    requestId: request.id,
    raisedBy: req.user.id,
    reason,
    status: 'open',
    createdAt: new Date().toISOString(),
  });
  broadcast('dispute.created', dispute);
  notify('admin_1', 'New dispute raised', `A dispute was raised on request ${request.id}.`, { disputeId: dispute.id });
  res.status(201).json(dispute);
});

module.exports = router;
