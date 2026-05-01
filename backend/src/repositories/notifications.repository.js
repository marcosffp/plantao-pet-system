'use strict';

const prisma = require('../prisma/client');

const create = (data) => prisma.notification.create({ data });

const findUnreadByUser = (userId) =>
  prisma.notification.findMany({
    where: { userId, readAt: null },
    orderBy: { createdAt: 'desc' },
  });

const findAllByUser = (userId) =>
  prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });

const findById = (id) => prisma.notification.findUnique({ where: { id } });

const markRead = (id, userId) =>
  prisma.notification.updateMany({
    where: { id, userId },
    data: { readAt: new Date() },
  });

const existsDuplicate = (userId, eventType, requestId) =>
  prisma.notification.findFirst({ where: { userId, eventType, requestId: requestId ?? null } });

module.exports = { create, findUnreadByUser, findAllByUser, findById, markRead, existsDuplicate };
