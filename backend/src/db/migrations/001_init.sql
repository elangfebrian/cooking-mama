-- Cooking Mama - skema awal (PostgreSQL)
-- Dijalankan oleh: npm run db:migrate

CREATE TABLE users (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  email         VARCHAR(255) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  avatar_url    VARCHAR(500) NOT NULL DEFAULT '',
  bio           TEXT NOT NULL DEFAULT '',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Email unik tanpa membedakan huruf besar/kecil
CREATE UNIQUE INDEX users_email_lower_uq ON users (lower(email));

CREATE TABLE categories (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  slug VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE recipes (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id  INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  title        VARCHAR(150) NOT NULL,
  description  TEXT NOT NULL DEFAULT '',
  image_url    VARCHAR(500) NOT NULL DEFAULT '',
  cook_minutes INTEGER NOT NULL DEFAULT 0 CHECK (cook_minutes >= 0),
  servings     INTEGER NOT NULL DEFAULT 1 CHECK (servings >= 1),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX recipes_user_idx     ON recipes (user_id);
CREATE INDEX recipes_category_idx ON recipes (category_id);
CREATE INDEX recipes_created_idx  ON recipes (created_at DESC, id DESC);

CREATE TABLE ingredients (
  id        SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  position  INTEGER NOT NULL,
  content   VARCHAR(300) NOT NULL,
  UNIQUE (recipe_id, position)
);

CREATE TABLE steps (
  id        SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  position  INTEGER NOT NULL,
  content   TEXT NOT NULL,
  UNIQUE (recipe_id, position)
);

CREATE TABLE comments (
  id         SERIAL PRIMARY KEY,
  recipe_id  INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    VARCHAR(1000) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX comments_recipe_idx ON comments (recipe_id, created_at DESC);

-- "Simpan" resep di frontend = favorites
CREATE TABLE favorites (
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipe_id  INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, recipe_id)
);
CREATE INDEX favorites_recipe_idx ON favorites (recipe_id);

-- Statistik "Pengikut" di halaman profil
CREATE TABLE follows (
  follower_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);
CREATE INDEX follows_following_idx ON follows (following_id);
