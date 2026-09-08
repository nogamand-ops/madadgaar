const { isNightHour } = require('./lib/geo');

/**
 * Pure pricing engine. Every number that reaches the customer is derived
 * here from an admin-configurable PricingRule — nothing is hardcoded in
 * the client apps.
 *
 * Customer sees: fuelCost (pass-through, fuel service only) + assistanceFee
 * + distanceFee + nightSurcharge - discount = total.
 *
 * Madadgaar only takes commission on the *service* portion (assistanceFee +
 * distanceFee + nightSurcharge - discount), never on the pass-through fuel
 * cost, which is owed to the fuel fulfillment partner.
 */
function estimatePrice({ rule, serviceKey, details = {}, distanceKm = 0, now = new Date() }) {
  if (!rule) throw new Error('pricing rule is required');

  const isNight = isNightHour(now, rule.nightStartHour, rule.nightEndHour);

  let fuelCost = 0;
  if (serviceKey === 'fuel') {
    const fuelType = details.fuelType === 'diesel' ? 'diesel' : 'petrol';
    const quantityLitres = Number(details.quantityLitres) || 0;
    const pricePerLitre = rule.fuelPricePerLitre?.[fuelType] ?? 0;
    fuelCost = Math.round(pricePerLitre * quantityLitres);
  }

  const billableKm = Math.max(0, distanceKm - (rule.freeKm ?? 0));
  const distanceFee = Math.round(billableKm * rule.perKmFee);
  const nightSurcharge = isNight ? Math.round(rule.nightSurchargeAmount ?? 0) : 0;
  const assistanceFee = Math.round(rule.baseServiceFee);
  const discount = 0;

  let serviceRevenue = assistanceFee + distanceFee + nightSurcharge - discount;
  if (rule.minFare && serviceRevenue < rule.minFare) {
    serviceRevenue = rule.minFare;
  }

  const platformCommission = Math.round(serviceRevenue * (rule.platformCommissionPct ?? 0));
  const helperEarnings = serviceRevenue - platformCommission;
  const total = fuelCost + serviceRevenue;

  return {
    serviceKey,
    isNight,
    breakdown: {
      fuelCost,
      assistanceFee,
      distanceFee,
      nightSurcharge,
      discount,
      total,
    },
    revenue: {
      serviceRevenue,
      platformCommission,
      helperEarnings,
      madadgaarRevenue: platformCommission,
    },
  };
}

module.exports = { estimatePrice };
