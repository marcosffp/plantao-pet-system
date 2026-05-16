'use strict';

const getKafka = require('./kafka.client');
const kafka = getKafka();

const producer = kafka.producer();
let connected = false;

const connect = async () => {
  if (!connected) {
    await producer.connect();
    connected = true;
    console.log('\x1b[32m[KAFKA PROD]\x1b[0m Producer conectado');
  }
};

const publish = async (topic, payload) => {
  try {
    await connect();
    await producer.send({
      topic,
      messages: [{ value: JSON.stringify(payload) }],
    });
    console.log(`\x1b[32m[KAFKA SEND]\x1b[0m Evento publicado no tópico [${topic}]`);
  } catch (err) {
    console.error(`\x1b[31m[KAFKA ERR]\x1b[0m Falha ao publicar no tópico [${topic}]:`, err.message);
  }
};

const disconnect = async () => {
  if (connected) {
    await producer.disconnect();
    connected = false;
  }
};

module.exports = { connect, publish, disconnect };
