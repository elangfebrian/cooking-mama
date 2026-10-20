/**
 * Mengisi database dengan data contoh. Aman dijalankan berulang (menghapus data lama).
 *   npm run db:seed
 */
const bcrypt = require('bcryptjs');
const env = require('../config/env');
const { pool } = require('../config/db');
const slugify = require('../utils/slugify');
const data = require('./seed-data');

const SEED_PASSWORD = 'password123';

async function main() {
  if (env.nodeEnv === 'production') throw new Error('Seed dilarang saat NODE_ENV=production');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      'TRUNCATE comments, favorites, follows, ingredients, steps, recipes, categories, users RESTART IDENTITY CASCADE',
    );

    // Kategori (urutan sama dengan chip di frontend; "Semua" hanya filter, bukan data)
    const catId = {};
    for (const name of data.categories) {
      const { rows } = await client.query(
        'INSERT INTO categories (name, slug) VALUES ($1, $2) RETURNING id',
        [name, slugify(name)],
      );
      catId[name] = rows[0].id;
    }

    // Pengguna
    const hash = await bcrypt.hash(SEED_PASSWORD, 10);
    const userId = {};
    for (const u of data.users) {
      const { rows } = await client.query(
        'INSERT INTO users (name, email, password_hash) VALUES ($1, $2, $3) RETURNING id',
        [u.name, u.email, hash],
      );
      userId[u.name] = rows[0].id;
    }

    // Resep: id eksplisit agar sama dengan mock frontend; id kecil = paling baru
    for (const r of data.recipes) {
      const hoursAgo = r.id <= 8 ? r.id : 24 + r.id;
      await client.query(
        `INSERT INTO recipes (id, user_id, category_id, title, description, image_url,
                              cook_minutes, servings, created_at, updated_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8, now() - make_interval(hours => $9), now() - make_interval(hours => $9))`,
        [r.id, userId[r.author], catId[r.category], r.title, r.description, r.image,
          r.cookMinutes, r.servings, hoursAgo],
      );
      for (const [i, text] of r.ingredients.entries()) {
        await client.query('INSERT INTO ingredients (recipe_id, position, content) VALUES ($1,$2,$3)', [r.id, i + 1, text]);
      }
      for (const [i, text] of r.steps.entries()) {
        await client.query('INSERT INTO steps (recipe_id, position, content) VALUES ($1,$2,$3)', [r.id, i + 1, text]);
      }
      for (const c of r.comments || []) {
        await client.query(
          `INSERT INTO comments (recipe_id, user_id, content, created_at)
           VALUES ($1,$2,$3, now() - make_interval(days => $4))`,
          [r.id, userId[c.user], c.text, c.daysAgo],
        );
      }
    }
    await client.query(`SELECT setval(pg_get_serial_sequence('recipes','id'), (SELECT MAX(id) FROM recipes))`);

    // Beberapa pengikut agar statistik profil tidak kosong
    for (const name of ['Bunda Sari', 'Mama Dina', 'Kak Lia']) {
      await client.query('INSERT INTO follows (follower_id, following_id) VALUES ($1,$2)', [userId[name], userId['Mama Rina']]);
    }

    await client.query('COMMIT');
    console.log(`[seed] ${data.categories.length} kategori, ${data.users.length} pengguna, ${data.recipes.length} resep.`);
    console.log(`[seed] Login contoh: mamarina@example.com / ${SEED_PASSWORD}`);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error('[seed] Gagal:', err.message);
  process.exit(1);
});
