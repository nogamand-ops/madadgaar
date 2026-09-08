const { verify } = require('../lib/token');
const { store } = require('../store');

/** Attaches req.user when a valid bearer token is present; does not itself reject. */
function attachUser(req, _res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  const payload = token ? verify(token) : null;
  req.user = payload ? store.getUser(payload.userId) : null;
  next();
}

/** Route guard: 401 if not authenticated. */
function requireAuth(req, res, next) {
  if (!req.user) return res.status(401).json({ error: 'unauthenticated' });
  next();
}

/** Route guard: 403 if authenticated but wrong role. */
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ error: 'unauthenticated' });
    if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'forbidden' });
    next();
  };
}

module.exports = { attachUser, requireAuth, requireRole };
