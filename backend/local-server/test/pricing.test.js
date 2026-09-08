const test = require('node:test');
const assert = require('node:assert/strict');
const { estimatePrice } = require('../src/pricing');

const dayRule = {
  baseServiceFee: 180,
  perKmFee: 20,
  freeKm: 2,
  minFare: 0,
  nightSurchargeAmount: 150,
  nightStartHour: 21,
  nightEndHour: 5,
  platformCommissionPct: 0.12,
  cancellationFeeFlat: 100,
  fuelPricePerLitre: { petrol: 280, diesel: 290 },
};

test('fuel pricing: fuel cost is a pass-through, not commissioned', () => {
  const result = estimatePrice({
    rule: dayRule,
    serviceKey: 'fuel',
    details: { fuelType: 'petrol', quantityLitres: 5 },
    distanceKm: 4,
    now: new Date('2026-01-01T12:00:00'), // daytime
  });

  assert.equal(result.breakdown.fuelCost, 1400); // 280 * 5
  assert.equal(result.breakdown.distanceFee, 40); // (4-2 free) * 20
  assert.equal(result.breakdown.nightSurcharge, 0);
  assert.equal(result.isNight, false);

  const serviceRevenue = result.breakdown.assistanceFee + result.breakdown.distanceFee + result.breakdown.nightSurcharge;
  assert.equal(result.revenue.serviceRevenue, serviceRevenue);
  assert.equal(result.revenue.platformCommission, Math.round(serviceRevenue * 0.12));
  assert.equal(result.revenue.helperEarnings, serviceRevenue - result.revenue.platformCommission);
  assert.equal(result.breakdown.total, result.breakdown.fuelCost + serviceRevenue);
  // Fuel cost never contributes to Madadgaar's commission.
  assert.equal(result.revenue.madadgaarRevenue, Math.round(serviceRevenue * 0.12));
});

test('night surcharge applies across midnight wrap and not during the day', () => {
  const night = estimatePrice({ rule: dayRule, serviceKey: 'battery', details: {}, distanceKm: 1, now: new Date('2026-01-01T23:00:00') });
  const day = estimatePrice({ rule: dayRule, serviceKey: 'battery', details: {}, distanceKm: 1, now: new Date('2026-01-01T14:00:00') });

  assert.equal(night.breakdown.nightSurcharge, 150);
  assert.equal(day.breakdown.nightSurcharge, 0);
});

test('minFare floors low-distance service revenue', () => {
  const result = estimatePrice({
    rule: { ...dayRule, baseServiceFee: 100, perKmFee: 5, minFare: 500 },
    serviceKey: 'battery',
    details: {},
    distanceKm: 0,
    now: new Date('2026-01-01T12:00:00'),
  });
  assert.equal(result.revenue.serviceRevenue, 500);
});
