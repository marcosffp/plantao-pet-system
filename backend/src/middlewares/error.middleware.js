'use strict';

const AppError = require('../utils/AppError');

const errorMiddleware = (err, req, res, next) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message });
  }

  // Prisma unique constraint violation
  if (err.code === 'P2002') {
    return res.status(409).json({ error: 'Registro já existe com estes dados' });
  }

  // Prisma record not found
  if (err.code === 'P2025') {
    return res.status(404).json({ error: 'Registro não encontrado' });
  }

  console.error('[ERROR]', err);
  res.status(500).json({ error: 'Erro interno do servidor' });
};

module.exports = errorMiddleware;
