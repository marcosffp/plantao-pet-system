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
  'review.created',
];

const saveAndEmit = async ({ userId, userRole, eventType, requestId, socketEvent, socketPayload }) => {
  const dup = await notificationsRepo.existsDuplicate(userId, eventType, requestId);
  if (dup) {
    console.log(`\x1b[33m[KAFKA DUPE]\x1b[0m Duplicata ignorada: ${eventType} para userId=${userId}`);
    return;
  }
  await notificationsRepo.create({ userId, userRole, eventType, payload: socketPayload, requestId: requestId ?? null });
  console.log(`\x1b[36m[SOCKET EMIT]\x1b[0m Emitindo ${socketEvent} para userId=${userId}`);
  emitToUser(userRole, userId, socketEvent, socketPayload);
};

const handlers = {
  'service_request.created': async (payload) => {
    console.log(`\x1b[35m[KAFKA RECV]\x1b[0m Recebido [service_request.created] - ID: ${payload.requestId}`);
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
    console.log(`\x1b[35m[KAFKA RECV]\x1b[0m Recebido [service_request.accepted] - ID: ${payload.requestId}`);
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
    console.log(`\x1b[35m[KAFKA RECV]\x1b[0m Recebido [service_request.refused] - ID: ${payload.requestId}`);
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
    console.log(`\x1b[35m[KAFKA RECV]\x1b[0m Recebido [service_request.in_progress] - ID: ${payload.requestId}`);
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
    console.log(`\x1b[35m[KAFKA RECV]\x1b[0m Recebido [service.completed] - ID: ${payload.requestId}`);
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

  'review.created': async (payload) => {
    console.log(`\x1b[35m[KAFKA RECV]\x1b[0m Recebido [review.created] - RequestID: ${payload.requestId}`);
    await saveAndEmit({
      userId: payload.caregiverId,
      userRole: 'caregiver',
      eventType: 'review.created',
      requestId: payload.requestId,
      socketEvent: 'new_review',
      socketPayload: {
        comment: payload.comment,
        newAverageRating: payload.averageRating,
      },
    });
  },
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const start = async () => {
  await consumer.connect();
  console.log('\x1b[35m[KAFKA CONS]\x1b[0m Consumer conectado');

  let subscribed = false;
  let attempts = 0;
  while (!subscribed) {
    try {
      for (const topic of TOPICS) {
        await consumer.subscribe({ topic, fromBeginning: false });
      }
      subscribed = true;
      console.log('\x1b[35m[KAFKA CONS]\x1b[0m Consumer inscrito nos tópicos');
    } catch (err) {
      attempts++;
      console.warn(`\x1b[33m[KAFKA WARN]\x1b[0m Aguardando tópicos (tentativa ${attempts})...`);
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
        console.error(`\x1b[31m[KAFKA ERR]\x1b[0m Erro ao processar [${topic}]:`, err.message);
      }
    },
  });
};

const disconnect = async () => {
  await consumer.disconnect();
};

module.exports = { start, disconnect };
