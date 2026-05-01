'use strict';

const petsRepo = require('../repositories/pets.repository');
const ownersRepo = require('../repositories/owners.repository');
const AppError = require('../utils/AppError');

const create = async (ownerId, petData, user) => {
  if (/*user.role === 'owner' && */user.id !== ownerId) {
    throw new AppError(403, 'Você não pode cadastrar pets para outro dono');
  }
  const owner = await ownersRepo.findById(ownerId);
  if (!owner) throw new AppError(404, 'Dono não encontrado');

  return petsRepo.create({ ...petData, ownerId });
};

const findByOwnerId = async (ownerId) => {
  const owner = await ownersRepo.findById(ownerId);
  if (!owner) throw new AppError(404, 'Dono não encontrado');
  return petsRepo.findByOwnerId(ownerId);
};

const findById = async (id) => {
  const pet = await petsRepo.findById(id);
  if (!pet) throw new AppError(404, 'Pet não encontrado');
  return pet;
};

module.exports = { create, findByOwnerId, findById };
