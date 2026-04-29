'use strict';

const serviceRequestsRepo = require('../repositories/service-requests.repository');
const petsRepo = require('../repositories/pets.repository');
const caregiversRepo = require('../repositories/caregivers.repository');
const producer = require('../kafka/kafka.producer');
const AppError = require('../utils/AppError');

const create = async ({ petId, serviceType, scheduledAt, meetingAddress }, user) => {
  // RN-15: pet deve pertencer ao dono autenticado
  const pet = await petsRepo.findById(petId);
  if (!pet) throw new AppError(404, 'Pet não encontrado');
  if (pet.ownerId !== user.id) throw new AppError(403, 'Este pet não pertence a você');

  // RN-02: scheduledAt deve ser no mínimo 2 horas no futuro
  const scheduled = new Date(scheduledAt);
  const minScheduled = new Date(Date.now() + 2 * 60 * 60 * 1000);
  if (scheduled < minScheduled) {
    throw new AppError(400, 'O agendamento deve ser feito com pelo menos 2 horas de antecedência');
  }

  // RN-01: pet não pode ter solicitação ativa (OPEN ou ACCEPTED)
  const active = await serviceRequestsRepo.findActivePetRequest(petId);
  if (active) throw new AppError(409, 'Pet já possui uma solicitação ativa');

  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

  const request = await serviceRequestsRepo.create({
    petId,
    ownerId: user.id,
    serviceType,
    scheduledAt: scheduled,
    meetingAddress,
    expiresAt,
  });

  await producer.publish('service_request.created', {
    requestId: request.id,
    serviceType,
    scheduledAt: request.scheduledAt,
    petName: pet.name,
    meetingAddress,
  });

  return request;
};

const findOpen = () => serviceRequestsRepo.findOpenRequests();

const findMine = (user) => {
  if (user.role === 'owner') return serviceRequestsRepo.findByOwner(user.id);
  return serviceRequestsRepo.findByCaregiver(user.id);
};

const findById = async (id) => {
  const request = await serviceRequestsRepo.findById(id);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  return request;
};

const accept = async (id, user) => {
  const request = await serviceRequestsRepo.findById(id);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  if (request.status !== 'OPEN') throw new AppError(409, 'Solicitação não está aberta para aceite');

  // RN-05: cuidador deve estar ACTIVE
  const caregiver = await caregiversRepo.findByIdWithPassword(user.id);
  if (!caregiver || caregiver.status !== 'ACTIVE') {
    throw new AppError(403, 'Cuidador inativo não pode aceitar solicitações');
  }

  // RN-06: máximo 3 solicitações IN_PROGRESS
  const inProgressCount = await caregiversRepo.countInProgress(user.id);
  if (inProgressCount >= 3) throw new AppError(409, 'Limite de atendimentos simultâneos atingido');

  const updated = await serviceRequestsRepo.updateStatus(id, 'ACCEPTED', { caregiverId: user.id });

  await producer.publish('service_request.accepted', {
    requestId: id,
    caregiverName: caregiver.name,
    caregiverPhone: caregiver.phone,
    ownerId: request.ownerId,
  });

  return updated;
};

const refuse = async (id, user) => {
  const request = await serviceRequestsRepo.findById(id);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  if (request.status !== 'ACCEPTED' || request.caregiverId !== user.id) {
    if (request.status !== 'OPEN') throw new AppError(409, 'Solicitação não pode ser recusada neste status');
  }

  // RN-07: status volta para OPEN ao recusar
  const updated = await serviceRequestsRepo.updateStatus(id, 'OPEN', { caregiverId: null });

  await producer.publish('service_request.refused', {
    requestId: id,
    caregiverId: user.id,
    refusedAt: new Date().toISOString(),
  });

  return updated;
};

const cancel = async (id, user) => {
  const request = await serviceRequestsRepo.findById(id);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  if (request.ownerId !== user.id) throw new AppError(403, 'Você não pode cancelar esta solicitação');

  // RN-04: dono só cancela se status for OPEN
  if (request.status !== 'OPEN') {
    throw new AppError(403, 'Solicitação não pode ser cancelada neste status');
  }

  return serviceRequestsRepo.updateStatus(id, 'CANCELLED');
};

const start = async (id, user) => {
  const request = await serviceRequestsRepo.findById(id);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  if (request.status !== 'ACCEPTED') throw new AppError(409, 'Solicitação não está aceita');

  // RN-09: apenas o cuidador atribuído pode iniciar
  if (request.caregiverId !== user.id) {
    throw new AppError(403, 'Apenas o cuidador atribuído pode iniciar o serviço');
  }

  const updated = await serviceRequestsRepo.updateStatus(id, 'IN_PROGRESS');

  await producer.publish('service_request.in_progress', {
    requestId: id,
    startedAt: new Date().toISOString(),
    ownerId: request.ownerId,
  });

  return updated;
};

const complete = async (id, user) => {
  const request = await serviceRequestsRepo.findById(id);
  if (!request) throw new AppError(404, 'Solicitação não encontrada');
  if (request.status !== 'IN_PROGRESS') throw new AppError(409, 'Serviço não está em andamento');

  // RN-10: apenas o cuidador atribuído pode concluir
  if (request.caregiverId !== user.id) {
    throw new AppError(403, 'Apenas o cuidador atribuído pode concluir o serviço');
  }

  const updated = await serviceRequestsRepo.updateStatus(id, 'COMPLETED');

  // RN-11: publicar evento service.completed
  await producer.publish('service.completed', {
    requestId: id,
    completedAt: new Date().toISOString(),
    caregiverId: user.id,
    ownerId: request.ownerId,
  });

  return updated;
};

module.exports = { create, findOpen, findMine, findById, accept, refuse, cancel, start, complete };
