'use strict';

const reviewsRepo = require('../repositories/reviews.repository');
const serviceRequestsRepo = require('../repositories/service-requests.repository');
const caregiversRepo = require('../repositories/caregivers.repository');
const producer = require('../kafka/kafka.producer');
const AppError = require('../utils/AppError');

const create = async ({ serviceRequestId, rating, comment }, user) => {
  const request = await serviceRequestsRepo.findById(serviceRequestId);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  if (request.ownerId !== user.id) throw new AppError(403, 'Você não pode avaliar esta solicitação');
  if (request.status !== 'COMPLETED') throw new AppError(400, 'Serviço ainda não foi concluído');
  const existing = await reviewsRepo.findByServiceRequestId(serviceRequestId);
  if (existing) throw new AppError(409, 'Esta solicitação já foi avaliada');

  const review = await reviewsRepo.create({
    serviceRequestId,
    ownerId: user.id,
    caregiverId: request.caregiverId,
    rating,
    comment,
  });

  const averageRating = await reviewsRepo.calculateAverageRating(request.caregiverId);
  await caregiversRepo.updateAverageRating(request.caregiverId, averageRating);

  await producer.publish('review.created', {
    caregiverId: request.caregiverId,
    averageRating,
    comment,
    requestId: serviceRequestId,
  });

  return review;
};

module.exports = { create };
