const { Pool } = require('pg');
const env = require('./env');

const pool = new Pool({ ...env.db, max: 10, idleTimeoutMillis: 30000 });

pool.on('error', (err) => {
  console.error('[db] Error pada koneksi idle:', err.message);
});

/** Query biasa. */
const query = (text, params) => pool.query(text, params);

/** Jalankan beberapa query dalam satu transaksi. */
async function withTransaction(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { pool, query, withTransaction };
