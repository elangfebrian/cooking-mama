const multer = require('multer');
const AppError = require('../utils/AppError');
const env = require('../config/env');

exports.notFound = (req, _res, next) => next(AppError.notFound(`Endpoint ${req.method} ${req.originalUrl} tidak ditemukan`));

// eslint-disable-next-line no-unused-vars
exports.errorHandler = (err, _req, res, _next) => {
  let status = 500;
  let code = 'INTERNAL_ERROR';
  let message = 'Terjadi kesalahan pada server';
  let details;

  if (err instanceof AppError) {
    ({ status, code, message, details } = err);
  } else if (err instanceof multer.MulterError) {
    status = err.code === 'LIMIT_FILE_SIZE' ? 413 : 400;
    code = err.code === 'LIMIT_FILE_SIZE' ? 'FILE_TOO_LARGE' : 'UPLOAD_ERROR';
    message = err.code === 'LIMIT_FILE_SIZE' ? `Ukuran foto maksimal ${env.maxUploadBytes / 1024 / 1024} MB` : 'Gagal mengunggah file';
  } else if (err.type === 'entity.parse.failed') {
    status = 400;
    code = 'BAD_JSON';
    message = 'Body request bukan JSON yang valid';
  } else if (err.code === '23505') {
    status = 409;
    code = 'CONFLICT';
    message = 'Data sudah ada';
  } else if (err.code === '23503') {
    status = 400;
    code = 'BAD_REFERENCE';
    message = 'Data yang direferensikan tidak ada';
  }

  if (status >= 500) console.error('[error]', err);

  const body = { success: false, error: { code, message } };
  if (details) body.error.details = details;
  if (status >= 500 && env.nodeEnv !== 'production') body.error.debug = err.message;
  res.status(status).json(body);
};
