'use strict';

const { Router } = require('express');
const serviceRequestsController = require('../controllers/service-requests.controller');
const { authenticate, requireOwner, requireCaregiver } = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const { createServiceRequestSchema } = require('../schemas/service-request.schema');

const router = Router();

/**
 * @swagger
 * /service-requests:
 *   post:
 *     summary: Criar solicitação de serviço
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.post('/', authenticate, requireOwner, validate(createServiceRequestSchema), serviceRequestsController.create);

/**
 * @swagger
 * /service-requests:
 *   get:
 *     summary: Listar solicitações abertas (para cuidadores)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.get('/', authenticate, requireCaregiver, serviceRequestsController.findOpen);

/**
 * @swagger
 * /service-requests/my:
 *   get:
 *     summary: Listar solicitações do usuário autenticado
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.get('/my', authenticate, serviceRequestsController.findMine);

/**
 * @swagger
 * /service-requests/{id}:
 *   get:
 *     summary: Buscar solicitação por ID
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.get('/:id', authenticate, serviceRequestsController.findById);

/**
 * @swagger
 * /service-requests/{id}/accept:
 *   patch:
 *     summary: Cuidador aceita a solicitação
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.patch('/:id/accept', authenticate, requireCaregiver, serviceRequestsController.accept);

/**
 * @swagger
 * /service-requests/{id}/refuse:
 *   patch:
 *     summary: Cuidador recusa a solicitação
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.patch('/:id/refuse', authenticate, requireCaregiver, serviceRequestsController.refuse);

/**
 * @swagger
 * /service-requests/{id}/cancel:
 *   patch:
 *     summary: Dono cancela a solicitação
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.patch('/:id/cancel', authenticate, requireOwner, serviceRequestsController.cancel);

/**
 * @swagger
 * /service-requests/{id}/start:
 *   patch:
 *     summary: Cuidador inicia o serviço
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.patch('/:id/start', authenticate, requireCaregiver, serviceRequestsController.start);

/**
 * @swagger
 * /service-requests/{id}/complete:
 *   patch:
 *     summary: Cuidador conclui o serviço
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 */
router.patch('/:id/complete', authenticate, requireCaregiver, serviceRequestsController.complete);

module.exports = router;
