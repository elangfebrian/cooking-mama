const bcrypt = require('bcryptjs');
const userModel = require('../models/user.model');
const { signToken } = require('../middleware/auth');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const { ok, created } = require('../utils/response');
const map = require('../utils/mappers');

exports.register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;
  if (await userModel.findByEmail(email)) {
    throw new AppError(409, 'EMAIL_TAKEN', 'Email sudah terdaftar', [{ field: 'email', message: 'Email sudah terdaftar' }]);
  }
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await userModel.create({ name, email, passwordHash });
  created(res, { token: signToken(user), user: map.user(user) });
});

exports.login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await userModel.findByEmail(email);
  // Pesan sengaja sama untuk email salah / password salah (cegah user enumeration)
  const valid = user && (await bcrypt.compare(password, user.password_hash));
  if (!valid) throw AppError.unauthorized('Email atau password salah');
  ok(res, { token: signToken(user), user: map.user(user) });
});

exports.me = asyncHandler(async (req, res) => {
  const user = await userModel.findById(req.user.id);
  if (!user) throw AppError.unauthorized('Akun tidak ditemukan');
  ok(res, map.user(user));
});
