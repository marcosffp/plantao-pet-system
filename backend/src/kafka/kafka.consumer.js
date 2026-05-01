'use strict';

const getKafka = require('./kafka.client');
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

const handlers = {
  'service_request.created': (payload) => {
    console.log('[KAFKA] service_request.created recebido:', payload);
    console.log(`[NOTIFY] Nova solicitação de serviço criada: ${payload.serviceType} para pet "${payload.petName}" em ${payload.meetingAddress}`);
  },
  'service_request.accepted': (payload) => {
    console.log('[KAFKA] service_request.accepted recebido:', payload);
    console.log(`[NOTIFY] Solicitação ${payload.requestId} aceita pelo cuidador ${payload.caregiverName} — notificar dono ${payload.ownerId}`);
  },
  'service_request.refused': (payload) => {
    console.log('[KAFKA] service_request.refused recebido:', payload);
    console.log(`[NOTIFY] Solicitação ${payload.requestId} recusada — voltando para OPEN`);
  },
  'service_request.in_progress': (payload) => {
    console.log('[KAFKA] service_request.in_progress recebido:', payload);
    console.log(`[NOTIFY] Serviço iniciado em ${payload.startedAt} — notificar dono ${payload.ownerId}`);
  },
  'service.completed': (payload) => {
    console.log('[KAFKA] service.completed recebido:', payload);
    console.log(`[NOTIFY] Serviço concluído em ${payload.completedAt} — notificar dono ${payload.ownerId} para avaliar`);
  },
  'service_request.expired': (payload) => {
    console.log('[KAFKA] service_request.expired recebido:', payload);
    console.log(`[NOTIFY] Solicitação ${payload.requestId} expirada em ${payload.expiredAt}`);
  },
  'review.created': (payload) => {
    console.log('[KAFKA] review.created recebido:', payload);
    console.log(`[NOTIFY] Nova avaliação para cuidador ${payload.caregiverId}: nota ${payload.newRating} — média agora ${payload.averageRating}`);
  },
};

const start = async () => {
  try {
    await consumer.connect();
    console.log('[KAFKA] Consumer conectado');

    for (const topic of TOPICS) {
      await consumer.subscribe({ topic, fromBeginning: false });
    }

    await consumer.run({
      eachMessage: async ({ topic, message }) => {
        try {
          const payload = JSON.parse(message.value.toString());
          const handler = handlers[topic];
          if (handler) handler(payload);
        } catch (err) {
          console.error(`[KAFKA] Erro ao processar mensagem do tópico "${topic}":`, err.message);
        }
      },
    });
  } catch (err) {
    console.error('[KAFKA] Falha ao iniciar consumer:', err.message);
  }
};

const disconnect = async () => {
  await consumer.disconnect();
};

module.exports = { start, disconnect };
