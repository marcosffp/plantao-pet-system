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

const update = async (petId, petData, user) => {
  const pet = await petsRepo.findById(petId);
  if (!pet) throw new AppError(404, 'Pet não encontrado');
  if (pet.ownerId !== user.id) throw new AppError(403, 'Acesso negado');
  return petsRepo.update(petId, petData);
};

const remove = async (petId, user) => {
  const pet = await petsRepo.findById(petId);
  if (!pet) throw new AppError(404, 'Pet não encontrado');
  if (pet.ownerId !== user.id) throw new AppError(403, 'Acesso negado');
  await petsRepo.remove(petId);
};

module.exports = { create, findByOwnerId, findById, update, remove };
