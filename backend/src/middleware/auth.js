const jwt = require('jsonwebtoken');
const env = require('../config/env');
const AppError = require('../utils/AppError');

exports.signToken = (user) =>
  jwt.sign({ sub: user.id, name: user.name }, env.jwt.secret, { expiresIn: env.jwt.expiresIn });

function readToken(req) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  return scheme === 'Bearer' && token ? token : null;
}

/** Wajib login: 401 bila token tidak ada / tidak valid / kedaluwarsa. */
exports.authRequired = (req, _res, next) => {
  const token = readToken(req);
  if (!token) return next(AppError.unauthorized());
  try {
    const payload = jwt.verify(token, env.jwt.secret);
    req.user = { id: Number(payload.sub), name: payload.name };
    next();
  } catch (err) {
    const msg = err.name === 'TokenExpiredError' ? 'Sesi telah berakhir, silakan login lagi' : 'Token tidak valid';
    next(AppError.unauthorized(msg));
  }
};

/** Opsional: tamu tetap boleh; bila token valid, req.user terisi. */
exports.authOptional = (req, _res, next) => {
  const token = readToken(req);
  if (token) {
    try {
      const payload = jwt.verify(token, env.jwt.secret);
      req.user = { id: Number(payload.sub), name: payload.name };
    } catch (_) {
      /* token rusak dianggap tamu */
    }
  }
  next();
};
