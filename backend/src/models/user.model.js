const { query } = require('../config/db');

const COLS = 'id, name, email, avatar_url, bio, created_at';

exports.findByEmail = async (email) => {
  const { rows } = await query('SELECT * FROM users WHERE lower(email) = lower($1)', [email]);
  return rows[0] || null;
};

exports.findById = async (id) => {
  const { rows } = await query(`SELECT ${COLS} FROM users WHERE id = $1`, [id]);
  return rows[0] || null;
};

exports.create = async ({ name, email, passwordHash }) => {
  const { rows } = await query(
    `INSERT INTO users (name, email, password_hash) VALUES ($1, $2, $3) RETURNING ${COLS}`,
    [name, email, passwordHash],
  );
  return rows[0];
};

exports.update = async (id, { name, bio, avatar_url }) => {
  const { rows } = await query(
    `UPDATE users SET
       name = COALESCE($2, name),
       bio = COALESCE($3, bio),
       avatar_url = COALESCE($4, avatar_url),
       updated_at = now()
     WHERE id = $1 RETURNING ${COLS}`,
    [id, name ?? null, bio ?? null, avatar_url ?? null],
  );
  return rows[0] || null;
};

/** Profil publik + statistik. viewerId (opsional) untuk status is_following. */
exports.profile = async (id, viewerId) => {
  const { rows } = await query(
    `SELECT u.id, u.name, u.avatar_url, u.bio, u.created_at,
       (SELECT COUNT(*)::int FROM recipes   WHERE user_id = u.id)      AS recipes_count,
       (SELECT COUNT(*)::int FROM favorites WHERE user_id = u.id)      AS saved_count,
       (SELECT COUNT(*)::int FROM follows   WHERE following_id = u.id) AS followers_count,
       (SELECT COUNT(*)::int FROM follows   WHERE follower_id = u.id)  AS following_count,
       EXISTS (SELECT 1 FROM follows WHERE follower_id = $2::int AND following_id = u.id) AS is_following
     FROM users u WHERE u.id = $1`,
    [id, viewerId ?? null],
  );
  return rows[0] || null;
};

exports.follow = (followerId, followingId) =>
  query('INSERT INTO follows (follower_id, following_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [followerId, followingId]);

exports.unfollow = (followerId, followingId) =>
  query('DELETE FROM follows WHERE follower_id = $1 AND following_id = $2', [followerId, followingId]);
