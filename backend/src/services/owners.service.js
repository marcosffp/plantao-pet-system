'use strict';

const ownersRepo = require('../repositories/owners.repository');
const AppError = require('../utils/AppError');

const findById = async (id) => {
  const owner = await ownersRepo.findById(id);
  if (!owner) throw new AppError(404, 'Dono não encontrado');
  return owner;
};

module.exports = { findById };
