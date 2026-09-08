const EARTH_RADIUS_KM = 6371;

function toRad(deg) {
  return (deg * Math.PI) / 180;
}

/** Great-circle distance in kilometres between two {lat,lng} points. */
function distanceKm(a, b) {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);

  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
  return EARTH_RADIUS_KM * c;
}

/** Rough city-traffic ETA in whole minutes for a given distance, min 2. */
function etaMinutes(km, avgSpeedKmh = 25) {
  return Math.max(2, Math.round((km / avgSpeedKmh) * 60));
}

/** Point that is `fraction` of the way from a to b (linear interpolation). */
function lerpPoint(a, b, fraction) {
  const t = Math.min(1, Math.max(0, fraction));
  return {
    lat: a.lat + (b.lat - a.lat) * t,
    lng: a.lng + (b.lng - a.lng) * t,
  };
}

/** True if the given Date falls within a night window that wraps midnight (e.g. 21 -> 5). */
function isNightHour(date, startHour, endHour) {
  const h = date.getHours();
  if (startHour === endHour) return false;
  if (startHour < endHour) return h >= startHour && h < endHour;
  return h >= startHour || h < endHour;
}

module.exports = { distanceKm, etaMinutes, lerpPoint, isNightHour };
