'use strict';

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const ownersRepo = require('../repositories/owners.repository');
const caregiversRepo = require('../repositories/caregivers.repository');
const AppError = require('../utils/AppError');

const registerOwner = async ({ name, email, phone, address, password }) => {
  if (await ownersRepo.findByEmail(email)) throw new AppError(409, 'Email já cadastrado');
  if (await ownersRepo.findByPhone(phone)) throw new AppError(409, 'Telefone já cadastrado');

  const passwordHash = await bcrypt.hash(password, 10);
  const owner = await ownersRepo.create({ name, email, phone, address, passwordHash });

  const token = jwt.sign({ id: owner.id, role: 'owner' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  return { ...owner, token };
};

const loginOwner = async ({ email, password }) => {
  const owner = await ownersRepo.findByEmail(email);
  if (!owner) throw new AppError(401, 'Credenciais inválidas');

  const valid = await bcrypt.compare(password, owner.passwordHash);
  if (!valid) throw new AppError(401, 'Credenciais inválidas');

  const token = jwt.sign({ id: owner.id, role: 'owner' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  return { token };
};

const registerCaregiver = async ({ name, email, phone, neighborhoods, services, password }) => {
  if (await caregiversRepo.findByEmail(email)) throw new AppError(409, 'Email já cadastrado');
  if (await caregiversRepo.findByPhone(phone)) throw new AppError(409, 'Telefone já cadastrado');

  const passwordHash = await bcrypt.hash(password, 10);
  const caregiver = await caregiversRepo.create({ name, email, phone, neighborhoods, services, passwordHash });

  const token = jwt.sign({ id: caregiver.id, role: 'caregiver' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  return { ...caregiver, token };
};

const loginCaregiver = async ({ email, password }) => {
  const caregiver = await caregiversRepo.findByEmail(email);
  if (!caregiver) throw new AppError(401, 'Credenciais inválidas');

  const valid = await bcrypt.compare(password, caregiver.passwordHash);
  if (!valid) throw new AppError(401, 'Credenciais inválidas');

  const token = jwt.sign({ id: caregiver.id, role: 'caregiver' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  return { token };
};

module.exports = { registerOwner, loginOwner, registerCaregiver, loginCaregiver };
