const { query, withTransaction } = require('../config/db');
const categoryModel = require('./category.model');
const AppError = require('../utils/AppError');

/** SELECT dasar: resep lengkap (bahan, langkah, komentar, status favorit untuk $1). */
const BASE = `
  SELECT r.id, r.title, r.description, r.image_url, r.cook_minutes, r.servings,
         r.created_at, r.updated_at,
         u.id AS author_id, u.name AS author, c.name AS category,
         COALESCE((SELECT json_agg(i.content ORDER BY i.position)
                   FROM ingredients i WHERE i.recipe_id = r.id), '[]'::json) AS ingredients,
         COALESCE((SELECT json_agg(s.content ORDER BY s.position)
                   FROM steps s WHERE s.recipe_id = r.id), '[]'::json) AS steps,
         COALESCE((SELECT json_agg(json_build_object(
                     'id', cm.id, 'user_id', cu.id, 'user', cu.name,
                     'text', cm.content, 'created_at', cm.created_at
                   ) ORDER BY cm.created_at DESC, cm.id DESC)
                   FROM comments cm JOIN users cu ON cu.id = cm.user_id
                   WHERE cm.recipe_id = r.id), '[]'::json) AS comments,
         EXISTS (SELECT 1 FROM favorites f
                 WHERE f.recipe_id = r.id AND f.user_id = $1::int) AS is_favorite
  FROM recipes r
  JOIN users u      ON u.id = r.user_id
  JOIN categories c ON c.id = r.category_id`;

const ORDER = 'ORDER BY r.created_at DESC, r.id DESC';

exports.findAll = async ({ q, category, author_id, page, limit }, viewerId) => {
  // Parameter filter dibuat mulai dari $1 agar bisa dipakai query COUNT apa adanya.
  const filterParams = [];
  const where = [];
  const add = (v) => { filterParams.push(v); return `$${filterParams.length}`; };

  if (category && category.toLowerCase() !== 'semua') {
    where.push(`lower(c.name) = lower(${add(category)})`);
  }
  if (author_id) where.push(`r.user_id = ${add(author_id)}`);
  if (q) {
    const p = add(`%${q.replace(/[\\%_]/g, '\\$&')}%`);
    where.push(`(r.title ILIKE ${p} OR EXISTS (SELECT 1 FROM ingredients i WHERE i.recipe_id = r.id AND i.content ILIKE ${p}))`);
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';

  const countRes = await query(
    `SELECT COUNT(*)::int AS total FROM recipes r JOIN categories c ON c.id = r.category_id ${whereSql}`,
    filterParams,
  );

  // Query daftar: $1 = viewer, jadi seluruh placeholder filter digeser +1.
  const shifted = whereSql.replace(/\$(\d+)/g, (_m, n) => `$${Number(n) + 1}`);
  const listParams = [viewerId ?? null, ...filterParams, limit, (page - 1) * limit];
  const limitP = `$${filterParams.length + 2}`;
  const offsetP = `$${filterParams.length + 3}`;
  const { rows } = await query(
    `${BASE} ${shifted} ${ORDER} LIMIT ${limitP} OFFSET ${offsetP}`,
    listParams,
  );
  return { rows, total: countRes.rows[0].total };
};

exports.findById = async (id, viewerId) => {
  const { rows } = await query(`${BASE} WHERE r.id = $2`, [viewerId ?? null, id]);
  return rows[0] || null;
};

exports.findFavorites = async (userId) => {
  const { rows } = await query(
    `${BASE} WHERE r.id IN (SELECT recipe_id FROM favorites WHERE user_id = $1)
     ORDER BY (SELECT created_at FROM favorites WHERE user_id = $1 AND recipe_id = r.id) DESC`,
    [userId],
  );
  return rows;
};

exports.ownerOf = async (id) => {
  const { rows } = await query('SELECT user_id FROM recipes WHERE id = $1', [id]);
  return rows[0] ? rows[0].user_id : null;
};

async function replaceList(client, table, recipeId, items) {
  await client.query(`DELETE FROM ${table} WHERE recipe_id = $1`, [recipeId]);
  if (!items.length) return;
  const values = items.map((_, i) => `($1, $${i * 2 + 2}, $${i * 2 + 3})`).join(', ');
  const params = [recipeId];
  items.forEach((text, i) => params.push(i + 1, text));
  await client.query(`INSERT INTO ${table} (recipe_id, position, content) VALUES ${values}`, params);
}

async function resolveCategory(client, name) {
  const id = await categoryModel.findIdByName(name, client);
  if (!id) throw AppError.validation([{ field: 'category', message: `Kategori "${name}" tidak ditemukan` }]);
  return id;
}

exports.create = (userId, data) =>
  withTransaction(async (client) => {
    const categoryId = await resolveCategory(client, data.category);
    const { rows } = await client.query(
      `INSERT INTO recipes (user_id, category_id, title, description, image_url, cook_minutes, servings)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
      [userId, categoryId, data.title, data.description, data.image_url, data.cook_minutes, data.servings],
    );
    const id = rows[0].id;
    await replaceList(client, 'ingredients', id, data.ingredients);
    await replaceList(client, 'steps', id, data.steps);
    return id;
  });

exports.update = (id, data) =>
  withTransaction(async (client) => {
    const categoryId = data.category ? await resolveCategory(client, data.category) : null;
    await client.query(
      `UPDATE recipes SET
         category_id  = COALESCE($2, category_id),
         title        = COALESCE($3, title),
         description  = COALESCE($4, description),
         image_url    = COALESCE($5, image_url),
         cook_minutes = COALESCE($6, cook_minutes),
         servings     = COALESCE($7, servings),
         updated_at   = now()
       WHERE id = $1`,
      [id, categoryId, data.title ?? null, data.description ?? null, data.image_url ?? null,
        data.cook_minutes ?? null, data.servings ?? null],
    );
    if (data.ingredients) await replaceList(client, 'ingredients', id, data.ingredients);
    if (data.steps) await replaceList(client, 'steps', id, data.steps);
  });

exports.remove = (id) => query('DELETE FROM recipes WHERE id = $1', [id]);

exports.exists = async (id) => {
  const { rows } = await query('SELECT 1 FROM recipes WHERE id = $1', [id]);
  return rows.length > 0;
};
