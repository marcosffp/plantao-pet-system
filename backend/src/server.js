'use strict';

require('dotenv').config();
const http = require('http');
const app = require('./app');
const { init: initSocket } = require('./socket/socket');
const producer = require('./kafka/kafka.producer');
const consumer = require('./kafka/kafka.consumer');
const expireRequestsJob = require('./jobs/expire-requests.job');

const PORT = process.env.PORT || 3000;

const start = async () => {
  try {
    const httpServer = http.createServer(app);
    initSocket(httpServer);

    await producer.connect();
    await consumer.start();
    expireRequestsJob.start();

    httpServer.listen(PORT, () => {
      console.log(`[SERVER] Plantão Pet API rodando na porta ${PORT}`);
      console.log(`[SERVER] Documentação: http://localhost:${PORT}/api-docs`);
      console.log(`[SERVER] WebSocket: ws://localhost:${PORT}`);
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
