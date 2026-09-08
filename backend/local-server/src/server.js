const http = require('http');
const express = require('express');
const cors = require('cors');

const { attachUser } = require('./middleware/auth');
const { initWs } = require('./ws');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const customerRoutes = require('./routes/customers');
const helperRoutes = require('./routes/helpers');
const cityRoutes = require('./routes/cities');
const serviceRoutes = require('./routes/services');
const pricingRoutes = require('./routes/pricing');
const requestRoutes = require('./routes/requests');
const adminRoutes = require('./routes/admin');

const PORT = process.env.PORT || 4000;

const app = express();
app.use(cors());
app.use(express.json());
app.use(attachUser);

app.get('/api/health', (_req, res) => res.json({ ok: true, service: 'madadgaar-local-server', mode: 'demo' }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/helpers', helperRoutes);
app.use('/api/cities', cityRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/pricing', pricingRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/admin', adminRoutes);

app.use((req, res) => res.status(404).json({ error: `no route for ${req.method} ${req.path}` }));
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'internal server error' });
});

const server = http.createServer(app);
initWs(server);

server.listen(PORT, () => {
  console.log(`Madadgaar local demo server listening on http://localhost:${PORT}`);
  console.log(`WebSocket broadcast available at ws://localhost:${PORT}/ws`);
  console.log('Demo Mode: in-memory data, no external services or API keys required.');
});
