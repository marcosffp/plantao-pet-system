'use strict';

const prisma = require('../prisma/client');

const findByPhone = (phone) => prisma.owner.findUnique({ where: { phone } });

const findById = (id) =>
  prisma.owner.findUnique({
    where: { id },
    select: { id: true, name: true, phone: true, address: true, createdAt: true },
  });

const create = (data) =>
  prisma.owner.create({
    data,
    select: { id: true, name: true, phone: true, address: true, createdAt: true },
  });

module.exports = { findByPhone, findById, create };
