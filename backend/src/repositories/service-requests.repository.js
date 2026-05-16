'use strict';

const prisma = require('../prisma/client');

const include = {
  pet: { select: { id: true, name: true, species: true, breed: true } },
  owner: { select: { id: true, name: true, phone: true } },
  caregiver: { select: { id: true, name: true, phone: true } },
  review: { select: { id: true, rating: true, comment: true } },
};

const create = (data) => prisma.serviceRequest.create({ data, include });

const findById = (id) => prisma.serviceRequest.findUnique({ where: { id }, include });

const findOpenRequests = () =>
  prisma.serviceRequest.findMany({ where: { status: 'OPEN' }, include, orderBy: { createdAt: 'desc' } });

const findByOwner = (ownerId) =>
  prisma.serviceRequest.findMany({ where: { ownerId }, include, orderBy: { createdAt: 'desc' } });

const findByCaregiver = (caregiverId) =>
  prisma.serviceRequest.findMany({ where: { caregiverId }, include, orderBy: { createdAt: 'desc' } });

const findActivePetRequest = (petId) =>
  prisma.serviceRequest.findFirst({ where: { petId, status: { in: ['OPEN', 'ACCEPTED'] } } });

const updateStatus = (id, status, extra = {}) =>
  prisma.serviceRequest.update({ where: { id }, data: { status, ...extra }, include });

const bulkCancel = (ids) =>
  prisma.serviceRequest.updateMany({ where: { id: { in: ids } }, data: { status: 'CANCELLED' } });

module.exports = { create, findById, findOpenRequests, findByOwner, findByCaregiver, findActivePetRequest, updateStatus, bulkCancel };
