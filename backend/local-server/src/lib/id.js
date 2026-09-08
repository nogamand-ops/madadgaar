const { randomUUID } = require('crypto');

function id(prefix) {
  const uuid = randomUUID().replace(/-/g, '').slice(0, 12);
  return prefix ? `${prefix}_${uuid}` : uuid;
}

module.exports = { id };
