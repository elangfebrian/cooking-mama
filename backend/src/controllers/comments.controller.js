const commentModel = require('../models/comment.model');
const recipeModel = require('../models/recipe.model');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const { ok, created } = require('../utils/response');
const map = require('../utils/mappers');

exports.list = asyncHandler(async (req, res) => {
  if (!(await recipeModel.exists(req.params.id))) throw AppError.notFound('Resep tidak ditemukan');
  const rows = await commentModel.listByRecipe(req.params.id);
  ok(res, rows.map(map.comment));
});

exports.create = asyncHandler(async (req, res) => {
  if (!(await recipeModel.exists(req.params.id))) throw AppError.notFound('Resep tidak ditemukan');
  const row = await commentModel.create(req.params.id, req.user.id, req.body.text);
  created(res, map.comment(row));
});

exports.remove = asyncHandler(async (req, res) => {
  const comment = await commentModel.findById(req.params.id);
  if (!comment) throw AppError.notFound('Komentar tidak ditemukan');
  if (comment.user_id !== req.user.id) throw AppError.forbidden('Anda hanya dapat menghapus komentar sendiri');
  await commentModel.remove(req.params.id);
  ok(res, { deleted: true });
});
