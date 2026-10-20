const env = require('../config/env');
const AppError = require('../utils/AppError');
const { created } = require('../utils/response');

exports.image = (req, res) => {
  if (!req.file) {
    throw AppError.validation([{ field: 'photo', message: 'File foto wajib dikirim (field "photo")' }]);
  }
  const base = env.publicBaseUrl || `${req.protocol}://${req.get('host')}`;
  created(res, { url: `${base}/uploads/${req.file.filename}` });
};
