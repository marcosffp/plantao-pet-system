'use strict';

require('dotenv').config();
const app = require('./app');
const producer = require('./kafka/kafka.producer');
const consumer = require('./kafka/kafka.consumer');
const expireRequestsJob = require('./jobs/expire-requests.job');

const PORT = process.env.PORT || 3000;

const start = async () => {
  try {
    await producer.connect();
    await consumer.start();
    expireRequestsJob.start();

    app.listen(PORT, () => {
      console.log(`[SERVER] Plantão Pet API rodando na porta ${PORT}`);
      console.log(`[SERVER] Documentação: http://localhost:${PORT}/api-docs`);
    });
  } catch (err) {
    console.error('[SERVER] Falha ao iniciar:', err.message);
    process.exit(1);
  }
};

process.on('SIGTERM', async () => {
  console.log('[SERVER] Encerrando...');
  await producer.disconnect();
  await consumer.disconnect();
  process.exit(0);
});

start();
