const env = require('./config/env');
const app = require('./app');
const { pool } = require('./config/db');

async function start() {
  try {
    await pool.query('SELECT 1');
  } catch (err) {
    console.error('[db] Tidak dapat terhubung ke PostgreSQL:', err.message);
    console.error('[db] Periksa DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD di .env dan pastikan PostgreSQL berjalan.');
    process.exit(1);
  }

  const server = app.listen(env.port, '0.0.0.0', () => {
    console.log(`Cooking Mama API berjalan di http://localhost:${env.port}  (docs: /docs)`);
  });

  const shutdown = () => server.close(() => pool.end().then(() => process.exit(0)));
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

start();
