'use strict';

const caregiversRepo = require('../repositories/caregivers.repository');
const reviewsRepo = require('../repositories/reviews.repository');
const AppError = require('../utils/AppError');

const findAll = () => caregiversRepo.findAllActive();

const findById = async (id) => {
  const caregiver = await caregiversRepo.findById(id);
  if (!caregiver) throw new AppError(404, 'Cuidador não encontrado');
  return caregiver;
};

const updateStatus = async (id, status, user) => {
  if (user.role === 'caregiver' && user.id !== id) {
    throw new AppError(403, 'Você só pode atualizar seu próprio status');
  }
  const caregiver = await caregiversRepo.findById(id);
  if (!caregiver) throw new AppError(404, 'Cuidador não encontrado');
  return caregiversRepo.updateStatus(id, status);
};

const findReviews = async (id) => {
  const caregiver = await caregiversRepo.findById(id);
  if (!caregiver) throw new AppError(404, 'Cuidador não encontrado');
  return reviewsRepo.findByCaregiver(id);
};

module.exports = { findAll, findById, updateStatus, findReviews };
