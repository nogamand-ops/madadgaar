const express = require('express');
const { store } = require('../store');
const { broadcast } = require('../ws');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth, requireRole('admin'));

function isToday(iso) {
  if (!iso) return false;
  const d = new Date(iso);
  const now = new Date();
  return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() && d.getDate() === now.getDate();
}

function periodStart(period) {
  const now = new Date();
  if (period === 'week') {
    const d = new Date(now);
    d.setDate(d.getDate() - 7);
    return d;
  }
  if (period === 'all') return new Date(0);
  const d = new Date(now);
  d.setHours(0, 0, 0, 0);
  return d;
}

router.get('/dashboard', (_req, res) => {
  const all = store.db.requests;
  const active = all.filter((r) => !['COMPLETED', 'CANCELLED'].includes(r.status));
  const todays = all.filter((r) => isToday(r.createdAt));
  const todaysCompleted = todays.filter((r) => r.status === 'COMPLETED');
  const todaysCancelled = todays.filter((r) => r.status === 'CANCELLED');
  const todaysRevenue = todaysCompleted.reduce((sum, r) => sum + (r.pricing?.revenue?.madadgaarRevenue ?? 0), 0);
  const todaysOrdersTotal = todays.length || 1;

  res.json({
    activeRequests: active.length,
    onlineHelpers: store.db.helperProfiles.filter((h) => h.availability === 'online').length,
    todaysOrders: todays.length,
    todaysRevenue,
    todaysCommission: todaysRevenue,
    completedJobsAllTime: all.filter((r) => r.status === 'COMPLETED').length,
    cancellationRatePct: Number(((todaysCancelled.length / todaysOrdersTotal) * 100).toFixed(1)),
  });
});

router.get('/analytics', (req, res) => {
  const period = ['today', 'week', 'all'].includes(req.query.period) ? req.query.period : 'today';
  const start = periodStart(period);
  const inPeriod = store.db.requests.filter((r) => new Date(r.createdAt) >= start);
  const completed = inPeriod.filter((r) => r.status === 'COMPLETED');
  const cancelled = inPeriod.filter((r) => r.status === 'CANCELLED');

  const gmv = completed.reduce((sum, r) => sum + (r.pricing?.breakdown?.total ?? 0), 0);
  const madadgaarRevenue = completed.reduce((sum, r) => sum + (r.pricing?.revenue?.madadgaarRevenue ?? 0), 0);
  const helperPayouts = completed.reduce((sum, r) => sum + (r.pricing?.revenue?.helperEarnings ?? 0), 0);
  const serviceRevenue = completed.reduce((sum, r) => sum + (r.pricing?.revenue?.serviceRevenue ?? 0), 0);

  const responseTimes = completed
    .filter((r) => r.acceptedAt)
    .map((r) => (new Date(r.acceptedAt) - new Date(r.createdAt)) / 60000);
  const avgResponseTimeMin = responseTimes.length
    ? Number((responseTimes.reduce((a, b) => a + b, 0) / responseTimes.length).toFixed(1))
    : 0;

  const totalFinished = completed.length + cancelled.length;

  res.json({
    period,
    orders: inPeriod.length,
    gmv,
    madadgaarRevenue,
    helperPayouts,
    averageOrderValue: completed.length ? Math.round(gmv / completed.length) : 0,
    averageResponseTimeMin: avgResponseTimeMin,
    completionRatePct: totalFinished ? Number(((completed.length / totalFinished) * 100).toFixed(1)) : 0,
    cancellationRatePct: totalFinished ? Number(((cancelled.length / totalFinished) * 100).toFixed(1)) : 0,
    takeRatePct: serviceRevenue ? Number(((madadgaarRevenue / serviceRevenue) * 100).toFixed(1)) : 0,
    isDemoData: true,
  });
});

router.get('/customers', (_req, res) => {
  const customers = store.db.users
    .filter((u) => u.role === 'customer')
    .map((u) => ({
      ...u,
      profile: store.getCustomerProfile(u.id),
      totalRequests: store.listRequests({ customerId: u.id }).length,
    }));
  res.json(customers);
});

router.get('/requests', (req, res) => {
  const { status, cityId } = req.query;
  let list = store.db.requests;
  if (status) list = list.filter((r) => (status === 'active' ? !['COMPLETED', 'CANCELLED'].includes(r.status) : r.status === status));
  if (cityId) list = list.filter((r) => r.cityId === cityId);
  res.json(list.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)));
});

router.get('/payments', (_req, res) => {
  res.json(store.db.payments.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)));
});

router.get('/disputes', (_req, res) => {
  res.json(
    store.listDisputes().map((d) => ({ ...d, request: store.getRequest(d.requestId) })).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
  );
});

router.patch('/disputes/:id', (req, res) => {
  const dispute = store.db.disputes.find((d) => d.id === req.params.id);
  if (!dispute) return res.status(404).json({ error: 'not found' });
  const { status, resolutionNote } = req.body || {};
  if (status) dispute.status = status;
  if (resolutionNote != null) dispute.resolutionNote = resolutionNote;
  broadcast('dispute.updated', dispute);
  res.json(dispute);
});

module.exports = router;
