const http = require('http');
const fs = require('fs');
const path = require('path');

const APPS = [
  { name: 'Customer app', dir: 'customer', port: 5173 },
  { name: 'Helper app', dir: 'helper', port: 5174 },
];

const MIME = {
  '.html': 'text/html', '.js': 'application/javascript', '.mjs': 'application/javascript',
  '.css': 'text/css', '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml', '.wasm': 'application/wasm', '.ico': 'image/x-icon',
  '.woff': 'font/woff', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.otf': 'font/otf',
};

for (const app of APPS) {
  const root = path.join(__dirname, app.dir);
  http
    .createServer((req, res) => {
      let filePath = path.normalize(path.join(root, decodeURIComponent(req.url.split('?')[0])));
      if (!filePath.startsWith(root) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
        filePath = path.join(root, 'index.html');
      }
      fs.readFile(filePath, (err, data) => {
        if (err) {
          res.writeHead(404);
          res.end('not found');
          return;
        }
        res.writeHead(200, { 'Content-Type': MIME[path.extname(filePath)] || 'application/octet-stream' });
        res.end(data);
      });
    })
    .listen(app.port, () => console.log(`${app.name}: http://localhost:${app.port}`));
}
