'use strict';

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const ownersRepo = require('../repositories/owners.repository');
const caregiversRepo = require('../repositories/caregivers.repository');
const AppError = require('../utils/AppError');

const registerOwner = async ({ name, phone, address, password }) => {
  const existing = await ownersRepo.findByPhone(phone);
  if (existing) throw new AppError(409, 'Telefone já cadastrado');

  const passwordHash = await bcrypt.hash(password, 10);
  return ownersRepo.create({ name, phone, address, passwordHash });
};

const loginOwner = async ({ phone, password }) => {
  const owner = await ownersRepo.findByPhone(phone);
  if (!owner) throw new AppError(401, 'Credenciais inválidas');

  const valid = await bcrypt.compare(password, owner.passwordHash);
  if (!valid) throw new AppError(401, 'Credenciais inválidas');

  const token = jwt.sign({ id: owner.id, role: 'owner' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  return { token };
};

const registerCaregiver = async ({ name, phone, neighborhoods, services, password }) => {
  const existing = await caregiversRepo.findByPhone(phone);
  if (existing) throw new AppError(409, 'Telefone já cadastrado');

  const passwordHash = await bcrypt.hash(password, 10);
  return caregiversRepo.create({ name, phone, neighborhoods, services, passwordHash });
};

const loginCaregiver = async ({ phone, password }) => {
  const caregiver = await caregiversRepo.findByPhone(phone);
  if (!caregiver) throw new AppError(401, 'Credenciais inválidas');

  const valid = await bcrypt.compare(password, caregiver.passwordHash);
  if (!valid) throw new AppError(401, 'Credenciais inválidas');

  const token = jwt.sign({ id: caregiver.id, role: 'caregiver' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  return { token };
};

module.exports = { registerOwner, loginOwner, registerCaregiver, loginCaregiver };
