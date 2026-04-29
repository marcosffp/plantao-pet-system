'use strict';

const jwt = require('jsonwebtoken');
const AppError = require('../utils/AppError');

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError(401, 'Token de autenticação não fornecido'));
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.id, role: decoded.role };
    next();
  } catch {
    next(new AppError(401, 'Token inválido ou expirado'));
  }
};

const requireOwner = (req, res, next) => {
  if (req.user.role !== 'owner') {
    return next(new AppError(403, 'Acesso restrito a donos de pets'));
  }
  next();
};

const requireCaregiver = (req, res, next) => {
  if (req.user.role !== 'caregiver') {
    return next(new AppError(403, 'Acesso restrito a cuidadores'));
  }
  next();
};

module.exports = { authenticate, requireOwner, requireCaregiver };
