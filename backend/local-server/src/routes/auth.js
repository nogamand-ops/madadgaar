const express = require('express');
const { store } = require('../store');
const { sign } = require('../lib/token');
const { id } = require('../lib/id');

const router = express.Router();

const DEMO_OTP = '1234';

// Pakistani mobile format: +92 3XX XXXXXXX
const PK_PHONE_RE = /^\+92 ?3\d{2} ?\d{7}$/;

router.post('/request-otp', (req, res) => {
  const { phone } = req.body || {};
  if (!phone || !PK_PHONE_RE.test(String(phone).trim())) {
    return res.status(400).json({ error: 'Enter a valid Pakistani mobile number, e.g. +923001234567' });
  }
  // Demo Mode: no real SMS provider is connected, so the OTP is fixed and
  // returned directly instead of pretending to text it.
  return res.json({ demoOtp: DEMO_OTP, message: 'Demo Mode: use the on-screen code, no SMS is actually sent.' });
});

router.post('/verify-otp', (req, res) => {
  const { phone, otp, role, name } = req.body || {};
  if (otp !== DEMO_OTP) {
    return res.status(400).json({ error: 'Incorrect code. (Demo Mode code is 1234.)' });
  }
  if (!phone || !PK_PHONE_RE.test(String(phone).trim())) {
    return res.status(400).json({ error: 'Invalid phone number' });
  }

  let user = store.getUserByPhone(phone);
  if (!user) {
    if (!['customer', 'helper'].includes(role)) {
      return res.status(400).json({ error: 'role must be customer or helper for a new account' });
    }
    user = store.createUser({
      id: id('user'),
      phone,
      name: name || 'New User',
      role,
      photoUrl: null,
      createdAt: new Date().toISOString(),
    });
    if (role === 'customer') store.getOrCreateCustomerProfile(user.id);
  }

  const token = sign({ userId: user.id });
  return res.json({ token, user });
});

module.exports = router;
