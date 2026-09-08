const express = require('express');
const { store } = require('../store');
const { broadcast } = require('../ws');
const { computeEstimate } = require('../estimate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', (req, res) => {
  const { cityId } = req.query;
  const rules = Object.values(store.db.pricingRules).filter((r) => !cityId || r.cityId === cityId);
  res.json(rules);
});

router.post('/estimate', (req, res) => {
  const { cityId, serviceKey, details, location } = req.body || {};
  if (!cityId || !serviceKey || !location?.lat || !location?.lng) {
    return res.status(400).json({ error: 'cityId, serviceKey and location are required' });
  }
  try {
    const result = computeEstimate({ cityId, serviceKey, details, location });
    res.json(result);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

router.get('/matching-config', (_req, res) => res.json(store.db.matchingConfig));

router.patch('/matching-config', requireAuth, requireRole('admin'), (req, res) => {
  const { weights, radiusRoundsKm, offerTimeoutSeconds } = req.body || {};
  if (weights) store.db.matchingConfig.weights = { ...store.db.matchingConfig.weights, ...weights };
  if (Array.isArray(radiusRoundsKm)) store.db.matchingConfig.radiusRoundsKm = radiusRoundsKm;
  if (offerTimeoutSeconds) store.db.matchingConfig.offerTimeoutSeconds = Number(offerTimeoutSeconds);
  res.json(store.db.matchingConfig);
});

router.patch('/:cityId/:serviceKey', requireAuth, requireRole('admin'), (req, res) => {
  const updated = store.updatePricingRule(req.params.cityId, req.params.serviceKey, req.body || {});
  if (!updated) return res.status(404).json({ error: 'not found' });
  broadcast('pricing.updated', updated);
  res.json(updated);
});

module.exports = router;
