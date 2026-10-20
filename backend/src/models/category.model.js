const { query } = require('../config/db');

exports.all = async () => {
  const { rows } = await query('SELECT id, name, slug FROM categories ORDER BY id');
  return rows;
};

exports.findIdByName = async (name, client = { query }) => {
  const { rows } = await client.query('SELECT id FROM categories WHERE lower(name) = lower($1)', [name]);
  return rows[0] ? rows[0].id : null;
};
