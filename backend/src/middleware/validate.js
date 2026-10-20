const AppError = require('../utils/AppError');

/** validate(schema, 'body' | 'query' | 'params') */
module.exports = (schema, source = 'body') => (req, _res, next) => {
  const result = schema.safeParse(req[source]);
  if (!result.success) {
    const details = result.error.issues.map((i) => ({
      field: i.path.join('.'),
      message: i.message,
    }));
    return next(AppError.validation(details));
  }
  req[source] = result.data;
  next();
};
