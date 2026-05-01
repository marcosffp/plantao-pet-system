'use strict';

const cron = require('node-cron');
const serviceRequestsRepo = require('../repositories/service-requests.repository');
const producer = require('../kafka/kafka.producer');

// RN-03: expira solicitações OPEN após 24h, rodando a cada hora
const start = () => {
  cron.schedule('0 * * * *', async () => {
    console.log('[CRON] Verificando solicitações expiradas...');
    try {
      const expired = await serviceRequestsRepo.findExpired();
      if (expired.length === 0) {
        console.log('[CRON] Nenhuma solicitação expirada encontrada');
        return;
      }

      const ids = expired.map((r) => r.id);
      await serviceRequestsRepo.bulkCancel(ids);
      console.log(`[CRON] ${ids.length} solicitação(ões) expirada(s) cancelada(s)`);

      for (const request of expired) {
        await producer.publish('service_request.expired', {
          requestId: request.id,
          expiredAt: new Date().toISOString(),
          ownerId: request.ownerId,
        });
      }
    } catch (err) {
      console.error('[CRON] Erro ao processar solicitações expiradas:', err.message);
    }
  });

  console.log('[CRON] Job de expiração de solicitações agendado (a cada hora)');
};

module.exports = { start };
