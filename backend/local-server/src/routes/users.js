const express = require('express');
const { store } = require('../store');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/:id', requireAuth, (req, res) => {
  const user = store.getUser(req.params.id);
  if (!user) return res.status(404).json({ error: 'not found' });
  res.json(user);
});

router.get('/:id/notifications', requireAuth, (req, res) => {
  if (req.user.id !== req.params.id && req.user.role !== 'admin') return res.status(403).json({ error: 'forbidden' });
  res.json(store.listNotifications(req.params.id));
});

router.post('/:id/notifications/read-all', requireAuth, (req, res) => {
  if (req.user.id !== req.params.id) return res.status(403).json({ error: 'forbidden' });
  store.listNotifications(req.params.id).forEach((n) => (n.read = true));
  res.json({ ok: true });
});

router.get('/:id/ratings', requireAuth, (req, res) => {
  res.json(store.listRatingsFor(req.params.id));
});

module.exports = router;
