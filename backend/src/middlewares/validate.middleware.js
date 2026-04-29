'use strict';

const AppError = require('../utils/AppError');

const validate = (schema) => (req, res, next) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    const messages = result.error.errors.map((e) => `${e.path.join('.')}: ${e.message}`).join('; ');
    return next(new AppError(400, messages));
  }
  req.body = result.data;
  next();
};

module.exports = validate;
