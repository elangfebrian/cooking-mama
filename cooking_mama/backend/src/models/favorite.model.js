const { query } = require('../config/db');

// Idempotent: menyimpan dua kali / menghapus yang tidak ada tidak error.
exports.add = (userId, recipeId) =>
  query('INSERT INTO favorites (user_id, recipe_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [userId, recipeId]);

exports.remove = (userId, recipeId) =>
  query('DELETE FROM favorites WHERE user_id = $1 AND recipe_id = $2', [userId, recipeId]);
