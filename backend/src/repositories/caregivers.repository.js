'use strict';

const prisma = require('../prisma/client');

const SAFE_SELECT = {
  id: true, name: true, email: true, phone: true,
  neighborhoods: true, services: true, averageRating: true, status: true, createdAt: true,
};

const findByEmail = (email) => prisma.caregiver.findUnique({ where: { email } });

const findByPhone = (phone) => prisma.caregiver.findUnique({ where: { phone } });

const findById = (id) => prisma.caregiver.findUnique({ where: { id }, select: SAFE_SELECT });

const findByIdWithPassword = (id) => prisma.caregiver.findUnique({ where: { id } });

const findAllActive = () =>
  prisma.caregiver.findMany({ where: { status: 'ACTIVE' }, select: SAFE_SELECT });

const create = (data) => prisma.caregiver.create({ data, select: SAFE_SELECT });

const updateStatus = (id, status) =>
  prisma.caregiver.update({ where: { id }, data: { status }, select: { id: true, name: true, status: true } });

const updateAverageRating = (id, averageRating) =>
  prisma.caregiver.update({ where: { id }, data: { averageRating } });

const countInProgress = (id) =>
  prisma.serviceRequest.count({ where: { caregiverId: id, status: 'IN_PROGRESS' } });

module.exports = {
  findByEmail, findByPhone, findById, findByIdWithPassword,
  findAllActive, create, updateStatus, updateAverageRating, countInProgress,
};
