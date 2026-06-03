'use strict';

const prisma = require('../prisma/client');

const create = (data) => prisma.pet.create({ data });

const findByOwnerId = (ownerId) =>
  prisma.pet.findMany({ where: { ownerId } });

const findById = (id) => prisma.pet.findUnique({ where: { id } });

const update = (id, data) => prisma.pet.update({ where: { id }, data });

const remove = (id) => prisma.pet.delete({ where: { id } });

module.exports = { create, findByOwnerId, findById, update, remove };
