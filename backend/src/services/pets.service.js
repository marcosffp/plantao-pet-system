'use strict';

const petsRepo = require('../repositories/pets.repository');
const ownersRepo = require('../repositories/owners.repository');
const AppError = require('../utils/AppError');

const create = async (petData, user) => {
  const owner = await ownersRepo.findById(user.id);
  if (!owner) throw new AppError(404, 'Dono não encontrado');
  return petsRepo.create({ ...petData, ownerId: user.id });
};

const findByOwnerId = async (ownerId) => {
  return petsRepo.findByOwnerId(ownerId);
};

const findById = async (id) => {
  const pet = await petsRepo.findById(id);
  if (!pet) throw new AppError(404, 'Pet não encontrado');
  return pet;
};

module.exports = { create, findByOwnerId, findById };
