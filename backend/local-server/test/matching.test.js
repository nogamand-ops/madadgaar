const test = require('node:test');
const assert = require('node:assert/strict');
const { rankCandidates, isEligible, DEFAULT_WEIGHTS } = require('../src/matching');

const request = { serviceKey: 'fuel', pickupLocation: { lat: 33.7, lng: 73.05 } };

function helper(overrides) {
  return {
    id: 'h1',
    verificationStatus: 'verified',
    availability: 'online',
    activeRequestId: null,
    servicesOffered: ['fuel'],
    rating: 4.5,
    completedJobs: 50,
    cancelledJobs: 2,
    currentLocation: { lat: 33.7, lng: 73.05 },
    ...overrides,
  };
}

test('unverified, offline, busy, or incapable helpers are excluded', () => {
  assert.equal(isEligible(helper({ verificationStatus: 'pending' }), request), false);
  assert.equal(isEligible(helper({ availability: 'offline' }), request), false);
  assert.equal(isEligible(helper({ activeRequestId: 'req_x' }), request), false);
  assert.equal(isEligible(helper({ servicesOffered: ['towing'] }), request), false);
  assert.equal(isEligible(helper(), request), true);
});

test('closer, higher-rated helpers rank first', () => {
  const near = helper({ id: 'near', currentLocation: { lat: 33.701, lng: 73.051 }, rating: 4.9 });
  const far = helper({ id: 'far', currentLocation: { lat: 33.75, lng: 73.1 }, rating: 4.9 });

  const ranked = rankCandidates([far, near], request, 10, DEFAULT_WEIGHTS);
  assert.equal(ranked[0].helper.id, 'near');
});

test('a radius round excludes helpers beyond it, forcing the caller to expand', () => {
  const farAway = helper({ id: 'far', currentLocation: { lat: 34.0, lng: 73.5 } });
  const ranked = rankCandidates([farAway], request, 2, DEFAULT_WEIGHTS);
  assert.equal(ranked.length, 0);

  const expanded = rankCandidates([farAway], request, 100, DEFAULT_WEIGHTS);
  assert.equal(expanded.length, 1);
});
