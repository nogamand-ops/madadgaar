const { WebSocketServer } = require('ws');

let wss = null;

function initWs(httpServer) {
  wss = new WebSocketServer({ server: httpServer, path: '/ws' });

  wss.on('connection', (socket) => {
    socket.isAlive = true;
    socket.on('pong', () => {
      socket.isAlive = true;
    });
    socket.send(JSON.stringify({ type: 'connection.ack', payload: { ok: true } }));
  });

  // Drop dead connections (e.g. a closed Chrome tab) so broadcast stays fast.
  const heartbeat = setInterval(() => {
    wss.clients.forEach((socket) => {
      if (!socket.isAlive) return socket.terminate();
      socket.isAlive = false;
      socket.ping();
    });
  }, 30000);
  wss.on('close', () => clearInterval(heartbeat));

  return wss;
}

/** Broadcast an event to every connected app (customer/helper/admin windows all filter client-side). */
function broadcast(type, payload) {
  if (!wss) return;
  const message = JSON.stringify({ type, payload, ts: new Date().toISOString() });
  wss.clients.forEach((socket) => {
    if (socket.readyState === 1) socket.send(message);
  });
}

module.exports = { initWs, broadcast };
