'use strict';

const prisma = require('../prisma/client');

const SAFE_SELECT = { id: true, name: true, email: true, phone: true, address: true, createdAt: true };

const findByEmail = (email) => prisma.owner.findUnique({ where: { email } });

const findByPhone = (phone) => prisma.owner.findUnique({ where: { phone } });

const findById = (id) => prisma.owner.findUnique({ where: { id }, select: SAFE_SELECT });

const create = (data) => prisma.owner.create({ data, select: SAFE_SELECT });

module.exports = { findByEmail, findByPhone, findById, create };
