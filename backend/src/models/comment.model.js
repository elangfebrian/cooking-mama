const { query } = require('../config/db');

const SELECT = `
  SELECT c.id, c.recipe_id, c.user_id, u.name AS user_name, c.content, c.created_at
  FROM comments c JOIN users u ON u.id = c.user_id`;

exports.listByRecipe = async (recipeId) => {
  const { rows } = await query(`${SELECT} WHERE c.recipe_id = $1 ORDER BY c.created_at DESC, c.id DESC`, [recipeId]);
  return rows;
};

exports.create = async (recipeId, userId, content) => {
  const { rows } = await query(
    'INSERT INTO comments (recipe_id, user_id, content) VALUES ($1, $2, $3) RETURNING id',
    [recipeId, userId, content],
  );
  const res = await query(`${SELECT} WHERE c.id = $1`, [rows[0].id]);
  return res.rows[0];
};

exports.findById = async (id) => {
  const { rows } = await query(`${SELECT} WHERE c.id = $1`, [id]);
  return rows[0] || null;
};

exports.remove = (id) => query('DELETE FROM comments WHERE id = $1', [id]);
