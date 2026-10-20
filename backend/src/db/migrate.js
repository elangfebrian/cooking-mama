/**
 * Migrasi sederhana: menjalankan file .sql di src/db/migrations berurutan
 * dan mencatatnya di tabel schema_migrations.
 *   node src/db/migrate.js          -> jalankan migrasi yang belum dijalankan
 *   node src/db/migrate.js --reset  -> HAPUS semua tabel lalu migrasi ulang (development saja)
 */
const fs = require('fs');
const path = require('path');
const env = require('../config/env');
const { pool } = require('../config/db');

async function main() {
  const reset = process.argv.includes('--reset');
  if (reset && env.nodeEnv === 'production') {
    throw new Error('--reset dilarang saat NODE_ENV=production');
  }

  const client = await pool.connect();
  try {
    if (reset) {
      console.log('[migrate] Menghapus schema public ...');
      await client.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
    }

    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        name       TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
      )`);

    const dir = path.join(__dirname, 'migrations');
    const files = fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();
    const { rows } = await client.query('SELECT name FROM schema_migrations');
    const done = new Set(rows.map((r) => r.name));

    for (const file of files) {
      if (done.has(file)) continue;
      console.log(`[migrate] Menjalankan ${file} ...`);
      const sql = fs.readFileSync(path.join(dir, file), 'utf8');
      try {
        await client.query('BEGIN');
        await client.query(sql);
        await client.query('INSERT INTO schema_migrations (name) VALUES ($1)', [file]);
        await client.query('COMMIT');
      } catch (err) {
        await client.query('ROLLBACK');
        throw err;
      }
    }
    console.log('[migrate] Selesai.');
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error('[migrate] Gagal:', err.message);
  process.exit(1);
});
