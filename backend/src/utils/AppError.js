/** Error yang aman ditampilkan ke klien. */
class AppError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

AppError.badRequest = (msg, details) => new AppError(400, 'BAD_REQUEST', msg, details);
AppError.unauthorized = (msg = 'Silakan login terlebih dahulu') => new AppError(401, 'UNAUTHORIZED', msg);
AppError.forbidden = (msg = 'Anda tidak memiliki akses ke data ini') => new AppError(403, 'FORBIDDEN', msg);
AppError.notFound = (msg = 'Data tidak ditemukan') => new AppError(404, 'NOT_FOUND', msg);
AppError.conflict = (msg) => new AppError(409, 'CONFLICT', msg);
AppError.validation = (details, msg = 'Data yang dikirim tidak valid') =>
  new AppError(422, 'VALIDATION_ERROR', msg, details);

module.exports = AppError;
