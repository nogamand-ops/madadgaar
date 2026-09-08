const express = require('express');
const { store } = require('../store');
const { broadcast } = require('../ws');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', (_req, res) => res.json(store.listCities()));

router.patch('/:id', requireAuth, requireRole('admin'), (req, res) => {
  const city = store.getCity(req.params.id);
  if (!city) return res.status(404).json({ error: 'not found' });
  const { enabled, serviceRadiusKm, operatingHours } = req.body || {};
  if (enabled != null) city.enabled = Boolean(enabled);
  if (serviceRadiusKm != null) city.serviceRadiusKm = Number(serviceRadiusKm);
  if (operatingHours) city.operatingHours = operatingHours;
  broadcast('city.updated', city);
  res.json(city);
});

module.exports = router;
