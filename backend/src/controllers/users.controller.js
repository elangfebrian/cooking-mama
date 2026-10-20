const userModel = require('../models/user.model');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const { ok } = require('../utils/response');
const map = require('../utils/mappers');

exports.profile = asyncHandler(async (req, res) => {
  const p = await userModel.profile(req.params.id, req.user?.id);
  if (!p) throw AppError.notFound('Pengguna tidak ditemukan');
  ok(res, p);
});

exports.updateMe = asyncHandler(async (req, res) => {
  const user = await userModel.update(req.user.id, req.body);
  ok(res, map.user(user));
});

exports.follow = asyncHandler(async (req, res) => {
  if (req.params.id === req.user.id) throw AppError.badRequest('Tidak dapat mengikuti diri sendiri');
  if (!(await userModel.findById(req.params.id))) throw AppError.notFound('Pengguna tidak ditemukan');
  await userModel.follow(req.user.id, req.params.id);
  ok(res, { user_id: req.params.id, is_following: true });
});

exports.unfollow = asyncHandler(async (req, res) => {
  await userModel.unfollow(req.user.id, req.params.id);
  ok(res, { user_id: req.params.id, is_following: false });
});
