'use strict';

const prisma = require('../prisma/client');

const create = (data) => prisma.pet.create({ data });

const findByOwnerId = (ownerId) =>
  prisma.pet.findMany({ where: { ownerId } });

const findById = (id) => prisma.pet.findUnique({ where: { id } });

module.exports = { create, findByOwnerId, findById };
