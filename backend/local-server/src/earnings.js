const { store } = require('./store');

function isSameDay(a, b) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

function daysAgo(date, n) {
  const d = new Date(date);
  d.setDate(d.getDate() - n);
  return d;
}

/** Helper earnings dashboard numbers, derived from completed requests — nothing stored redundantly. */
function computeHelperEarnings(helperId) {
  const now = new Date();
  const weekAgo = daysAgo(now, 7);
  const completed = store.db.requests.filter((r) => r.helperId === helperId && r.status === 'COMPLETED');

  let today = 0;
  let week = 0;
  let total = 0;
  for (const r of completed) {
    const earned = r.pricing?.revenue?.helperEarnings ?? 0;
    const completedAt = new Date(r.completedAt);
    total += earned;
    if (completedAt >= weekAgo) week += earned;
    if (isSameDay(completedAt, now)) today += earned;
  }

  const helper = store.getHelperProfile(helperId);
  const withdrawn = helper?.withdrawnTotalPaisa ?? 0;
  const availableBalance = Math.max(0, total - withdrawn);

  return {
    today,
    week,
    total,
    completedJobs: completed.length,
    availableBalance,
  };
}

module.exports = { computeHelperEarnings };
