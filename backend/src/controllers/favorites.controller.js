const favoriteModel = require('../models/favorite.model');
const recipeModel = require('../models/recipe.model');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const { ok } = require('../utils/response');
const map = require('../utils/mappers');

exports.list = asyncHandler(async (req, res) => {
  const rows = await recipeModel.findFavorites(req.user.id);
  ok(res, rows.map(map.recipe));
});

exports.add = asyncHandler(async (req, res) => {
  if (!(await recipeModel.exists(req.params.id))) throw AppError.notFound('Resep tidak ditemukan');
  await favoriteModel.add(req.user.id, req.params.id);
  ok(res, { recipe_id: req.params.id, is_favorite: true });
});

exports.remove = asyncHandler(async (req, res) => {
  await favoriteModel.remove(req.user.id, req.params.id);
  ok(res, { recipe_id: req.params.id, is_favorite: false });
});
