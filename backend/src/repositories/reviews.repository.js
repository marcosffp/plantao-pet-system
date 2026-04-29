'use strict';

const prisma = require('../prisma/client');

const create = (data) =>
  prisma.review.create({
    data,
    include: {
      owner: { select: { id: true, name: true } },
      caregiver: { select: { id: true, name: true } },
    },
  });

const findByServiceRequestId = (serviceRequestId) =>
  prisma.review.findUnique({ where: { serviceRequestId } });

const findByCaregiver = (caregiverId) =>
  prisma.review.findMany({
    where: { caregiverId },
    include: { owner: { select: { id: true, name: true } } },
    orderBy: { createdAt: 'desc' },
  });

const calculateAverageRating = async (caregiverId) => {
  const result = await prisma.review.aggregate({
    where: { caregiverId },
    _avg: { rating: true },
  });
  return result._avg.rating || 0;
};

module.exports = { create, findByServiceRequestId, findByCaregiver, calculateAverageRating };
