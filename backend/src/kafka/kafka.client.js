'use strict';

const { Kafka } = require('kafkajs');

let kafka;

const getKafka = () => {
  if (!kafka) {
    kafka = new Kafka({
      clientId: 'plantao-pet-api',
      brokers: [process.env.KAFKA_BROKER || 'localhost:9092'],
      retry: {
        initialRetryTime: 300,
        retries: 8,
      },
    });
  }
  return kafka;
};

module.exports = getKafka;