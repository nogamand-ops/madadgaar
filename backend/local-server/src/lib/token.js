const crypto = require('crypto');

// Local-only demo secret. A real deployment would source this from an
// environment variable and use a real auth provider (Supabase/Firebase
// phone-OTP) instead of this signed-token stand-in.
const SECRET = process.env.MADADGAAR_TOKEN_SECRET || 'madadgaar-local-demo-secret';

function sign(payload) {
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const sig = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  return `${body}.${sig}`;
}

function verify(token) {
  if (!token || typeof token !== 'string' || !token.includes('.')) return null;
  const [body, sig] = token.split('.');
  const expected = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  if (sig !== expected) return null;
  try {
    return JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  } catch {
    return null;
  }
}

module.exports = { sign, verify };
