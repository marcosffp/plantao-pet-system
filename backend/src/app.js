'use strict';

const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const authRoutes = require('./routes/auth.routes');
const ownersRoutes = require('./routes/owners.routes');
const petsRoutes = require('./routes/pets.routes');
const petsDirectRoutes = require('./routes/pets-direct.routes');
const caregiversRoutes = require('./routes/caregivers.routes');
const serviceRequestsRoutes = require('./routes/service-requests.routes');
const reviewsRoutes = require('./routes/reviews.routes');
const notificationsRoutes = require('./routes/notifications.routes');
const errorMiddleware = require('./middlewares/error.middleware');

const app = express();

app.use(cors());
app.use(express.json());

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Plantão Pet API',
      version: '1.0.0',
      description: 'API REST da plataforma Plantão Pet — matchmaking entre donos de pets e cuidadores',
    },
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
    },
  },
  apis: ['./src/routes/*.js'],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use('/auth', authRoutes);
app.use('/owners', ownersRoutes);
app.use('/owners', petsRoutes);
app.use('/pets', petsDirectRoutes);
app.use('/caregivers', caregiversRoutes);
app.use('/service-requests', serviceRequestsRoutes);
app.use('/reviews', reviewsRoutes);
app.use('/notifications', notificationsRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

app.use(errorMiddleware);

module.exports = app;
