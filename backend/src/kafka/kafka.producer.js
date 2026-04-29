'use strict';

const kafka = require('./kafka.client');

const producer = kafka.producer();
let connected = false;

const connect = async () => {
  if (!connected) {
    await producer.connect();
    connected = true;
    console.log('[KAFKA] Producer conectado');
  }
};

const publish = async (topic, payload) => {
  try {
    await connect();
    await producer.send({
      topic,
      messages: [{ value: JSON.stringify(payload) }],
    });
    console.log(`[KAFKA] Evento publicado no tópico "${topic}":`, payload);
  } catch (err) {
    console.error(`[KAFKA] Falha ao publicar no tópico "${topic}":`, err.message);
  }
};

const disconnect = async () => {
  if (connected) {
    await producer.disconnect();
    connected = false;
  }
};

module.exports = { connect, publish, disconnect };
