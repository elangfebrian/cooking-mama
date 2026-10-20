const recipeModel = require('../models/recipe.model');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const { ok, created } = require('../utils/response');
const map = require('../utils/mappers');

async function assertOwner(recipeId, userId) {
  const owner = await recipeModel.ownerOf(recipeId);
  if (owner === null) throw AppError.notFound('Resep tidak ditemukan');
  if (owner !== userId) throw AppError.forbidden('Anda hanya dapat mengubah resep milik sendiri');
}

exports.list = asyncHandler(async (req, res) => {
  const { rows, total } = await recipeModel.findAll(req.query, req.user?.id);
  const { page, limit } = req.query;
  ok(res, rows.map(map.recipe), { page, limit, total, total_pages: Math.max(1, Math.ceil(total / limit)) });
});

exports.get = asyncHandler(async (req, res) => {
  const row = await recipeModel.findById(req.params.id, req.user?.id);
  if (!row) throw AppError.notFound('Resep tidak ditemukan');
  ok(res, map.recipe(row));
});

exports.create = asyncHandler(async (req, res) => {
  const id = await recipeModel.create(req.user.id, req.body);
  const row = await recipeModel.findById(id, req.user.id);
  created(res, map.recipe(row));
});

exports.update = asyncHandler(async (req, res) => {
  await assertOwner(req.params.id, req.user.id);
  await recipeModel.update(req.params.id, req.body);
  const row = await recipeModel.findById(req.params.id, req.user.id);
  ok(res, map.recipe(row));
});

exports.remove = asyncHandler(async (req, res) => {
  await assertOwner(req.params.id, req.user.id);
  await recipeModel.remove(req.params.id);
  ok(res, { deleted: true });
});
