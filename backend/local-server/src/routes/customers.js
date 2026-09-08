const express = require('express');
const { store } = require('../store');
const { id } = require('../lib/id');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

function assertSelf(req, res, customerId) {
  if (req.user.id !== customerId && req.user.role !== 'admin') {
    res.status(403).json({ error: 'forbidden' });
    return false;
  }
  return true;
}

router.get('/:id', requireAuth, (req, res) => {
  if (!assertSelf(req, res, req.params.id)) return;
  const profile = store.getOrCreateCustomerProfile(req.params.id);
  res.json(profile);
});

router.get('/:id/vehicles', requireAuth, (req, res) => {
  if (!assertSelf(req, res, req.params.id)) return;
  res.json(store.listVehicles(req.params.id));
});

router.post('/:id/vehicles', requireAuth, (req, res) => {
  if (!assertSelf(req, res, req.params.id)) return;
  const b = req.body || {};
  if (!b.type || !b.make || !b.model) return res.status(400).json({ error: 'type, make and model are required' });

  const vehicle = store.addVehicle({
    id: id('veh'),
    customerId: req.params.id,
    type: b.type,
    make: b.make,
    model: b.model,
    year: b.year || null,
    fuelType: b.fuelType || 'petrol',
    nickname: b.nickname || null,
  });
  const profile = store.getOrCreateCustomerProfile(req.params.id);
  if (!profile.defaultVehicleId) profile.defaultVehicleId = vehicle.id;
  res.status(201).json(vehicle);
});

router.delete('/:id/vehicles/:vehicleId', requireAuth, (req, res) => {
  if (!assertSelf(req, res, req.params.id)) return;
  store.removeVehicle(req.params.vehicleId);
  const profile = store.getOrCreateCustomerProfile(req.params.id);
  if (profile.defaultVehicleId === req.params.vehicleId) profile.defaultVehicleId = null;
  res.status(204).end();
});

router.patch('/:id', requireAuth, (req, res) => {
  if (!assertSelf(req, res, req.params.id)) return;
  const profile = store.getOrCreateCustomerProfile(req.params.id);
  const { savedLocations, defaultVehicleId } = req.body || {};
  if (Array.isArray(savedLocations)) profile.savedLocations = savedLocations;
  if (defaultVehicleId !== undefined) profile.defaultVehicleId = defaultVehicleId;
  res.json(profile);
});

module.exports = router;
