const express = require('express');
const { store } = require('../store');
const { broadcast } = require('../ws');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', (_req, res) => res.json(store.listServices()));

router.patch('/:key', requireAuth, requireRole('admin'), (req, res) => {
  const service = store.db.services.find((s) => s.key === req.params.key);
  if (!service) return res.status(404).json({ error: 'not found' });
  if (req.body?.active != null) service.active = Boolean(req.body.active);
  broadcast('service.updated', service);
  res.json(service);
});

module.exports = router;
