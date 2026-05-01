'use strict';

const getKafka = require('./kafka.client');
const caregiversRepo = require('../repositories/caregivers.repository');
const notificationsRepo = require('../repositories/notifications.repository');
const { emitToUser } = require('../socket/socket');

const kafka = getKafka();
const consumer = kafka.consumer({ groupId: 'plantao-pet-group' });

const TOPICS = [
  'service_request.created',
  'service_request.accepted',
  'service_request.refused',
  'service_request.in_progress',
  'service.completed',
  'service_request.expired',
  'review.created',
];

const saveAndEmit = async ({ userId, userRole, eventType, requestId, socketEvent, socketPayload }) => {
  const dup = await notificationsRepo.existsDuplicate(userId, eventType, requestId);
  if (dup) {
    console.log(`[KAFKA] Duplicata ignorada: ${eventType} para userId=${userId}`);
    return;
  }
  await notificationsRepo.create({ userId, userRole, eventType, payload: socketPayload, requestId: requestId ?? null });
  emitToUser(userRole, userId, socketEvent, socketPayload);
};

const handlers = {
  'service_request.created': async (payload) => {
    console.log('[KAFKA] service_request.created recebido:', payload);
    const caregivers = await caregiversRepo.findAllActive();
    for (const caregiver of caregivers) {
      await saveAndEmit({
        userId: caregiver.id,
        userRole: 'caregiver',
        eventType: 'service_request.created',
        requestId: payload.requestId,
        socketEvent: 'new_request',
        socketPayload: {
          requestId: payload.requestId,
          serviceType: payload.serviceType,
          petName: payload.petName,
          meetingAddress: payload.meetingAddress,
          scheduledAt: payload.scheduledAt,
        },
      });
    }
  },

  'service_request.accepted': async (payload) => {
    console.log('[KAFKA] service_request.accepted recebido:', payload);
    await saveAndEmit({
      userId: payload.ownerId,
      userRole: 'owner',
      eventType: 'service_request.accepted',
      requestId: payload.requestId,
      socketEvent: 'request_accepted',
      socketPayload: {
        requestId: payload.requestId,
        caregiverName: payload.caregiverName,
        caregiverPhone: payload.caregiverPhone,
      },
    });
  },

  'service_request.refused': async (payload) => {
    console.log('[KAFKA] service_request.refused recebido:', payload);
    await saveAndEmit({
      userId: payload.ownerId,
      userRole: 'owner',
      eventType: 'service_request.refused',
      requestId: payload.requestId,
      socketEvent: 'request_refused',
      socketPayload: {
        requestId: payload.requestId,
        newStatus: 'OPEN',
      },
    });
  },

  'service_request.in_progress': async (payload) => {
    console.log('[KAFKA] service_request.in_progress recebido:', payload);
    await saveAndEmit({
      userId: payload.ownerId,
      userRole: 'owner',
      eventType: 'service_request.in_progress',
      requestId: payload.requestId,
      socketEvent: 'service_started',
      socketPayload: {
        requestId: payload.requestId,
        startedAt: payload.startedAt,
      },
    });
  },

  'service.completed': async (payload) => {
    console.log('[KAFKA] service.completed recebido:', payload);
    await saveAndEmit({
      userId: payload.ownerId,
      userRole: 'owner',
      eventType: 'service.completed',
      requestId: payload.requestId,
      socketEvent: 'service_completed',
      socketPayload: {
        requestId: payload.requestId,
        completedAt: payload.completedAt,
      },
    });
  },

  'service_request.expired': async (payload) => {
    console.log('[KAFKA] service_request.expired recebido:', payload);
    await saveAndEmit({
      userId: payload.ownerId,
      userRole: 'owner',
      eventType: 'service_request.expired',
      requestId: payload.requestId,
      socketEvent: 'request_expired',
      socketPayload: {
        requestId: payload.requestId,
        expiredAt: payload.expiredAt,
      },
    });
  },

  'review.created': async (payload) => {
    console.log('[KAFKA] review.created recebido:', payload);
    await saveAndEmit({
      userId: payload.caregiverId,
      userRole: 'caregiver',
      eventType: 'review.created',
      requestId: payload.requestId,
      socketEvent: 'new_review',
      socketPayload: {
        rating: payload.newRating,
        comment: payload.comment,
        newAverageRating: payload.averageRating,
      },
    });
  },
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const start = async () => {
  await consumer.connect();
  console.log('[KAFKA] Consumer conectado');

  let subscribed = false;
  let attempts = 0;
  while (!subscribed) {
    try {
      for (const topic of TOPICS) {
        await consumer.subscribe({ topic, fromBeginning: false });
      }
      subscribed = true;
      console.log('[KAFKA] Consumer inscrito nos tópicos');
    } catch (err) {
      attempts++;
      console.warn(`[KAFKA] Aguardando tópicos (tentativa ${attempts})...`);
      await sleep(3000);
    }
  }

  await consumer.run({
    eachMessage: async ({ topic, message }) => {
      try {
        const payload = JSON.parse(message.value.toString());
        const handler = handlers[topic];
        if (handler) await handler(payload);
      } catch (err) {
        console.error(`[KAFKA] Erro ao processar "${topic}":`, err.message);
      }
    },
  });
};

const disconnect = async () => {
  await consumer.disconnect();
};

module.exports = { start, disconnect };
