const router = require('express').Router();
const validate = require('../middleware/validate');
const { authRequired, authOptional } = require('../middleware/auth');
const { imageUpload } = require('../middleware/upload');
const v = require('../validators');

const auth = require('../controllers/auth.controller');
const recipes = require('../controllers/recipes.controller');
const comments = require('../controllers/comments.controller');
const favorites = require('../controllers/favorites.controller');
const categories = require('../controllers/categories.controller');
const users = require('../controllers/users.controller');
const uploads = require('../controllers/uploads.controller');

router.get('/health', (_req, res) => res.json({ success: true, data: { status: 'ok' } }));

// ---- Auth ----
router.post('/auth/register', validate(v.register), auth.register);
router.post('/auth/login', validate(v.login), auth.login);
router.get('/auth/me', authRequired, auth.me);

// ---- Kategori ----
router.get('/categories', categories.list);

// ---- Resep ----
router.get('/recipes', authOptional, validate(v.recipeList, 'query'), recipes.list);
router.post('/recipes', authRequired, validate(v.recipeCreate), recipes.create);
router.get('/recipes/:id', authOptional, validate(v.idParam, 'params'), recipes.get);
router.put('/recipes/:id', authRequired, validate(v.idParam, 'params'), validate(v.recipeUpdate), recipes.update);
router.delete('/recipes/:id', authRequired, validate(v.idParam, 'params'), recipes.remove);

// ---- Komentar ----
router.get('/recipes/:id/comments', validate(v.idParam, 'params'), comments.list);
router.post('/recipes/:id/comments', authRequired, validate(v.idParam, 'params'), validate(v.comment), comments.create);
router.delete('/comments/:id', authRequired, validate(v.idParam, 'params'), comments.remove);

// ---- Favorit (tombol "Simpan") ----
router.get('/favorites', authRequired, favorites.list);
router.put('/recipes/:id/favorite', authRequired, validate(v.idParam, 'params'), favorites.add);
router.delete('/recipes/:id/favorite', authRequired, validate(v.idParam, 'params'), favorites.remove);

// ---- Profil & follow ----
router.patch('/users/me', authRequired, validate(v.profileUpdate), users.updateMe);
router.get('/users/:id', authOptional, validate(v.idParam, 'params'), users.profile);
router.put('/users/:id/follow', authRequired, validate(v.idParam, 'params'), users.follow);
router.delete('/users/:id/follow', authRequired, validate(v.idParam, 'params'), users.unfollow);

// ---- Upload foto (multipart, field "photo") ----
router.post('/uploads/image', authRequired, imageUpload, uploads.image);

module.exports = router;
