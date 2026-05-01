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
 *     summary: Criar solicitação de serviço (apenas donos)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [petId, serviceType, scheduledAt, meetingAddress]
 *             properties:
 *               petId:
 *                 type: string
 *                 format: uuid
 *                 example: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
 *               serviceType:
 *                 type: string
 *                 enum: [WALK_30MIN, WALK_1H, HOME_VISIT, HOSTING]
 *                 example: WALK_30MIN
 *               scheduledAt:
 *                 type: string
 *                 format: date-time
 *                 example: "2026-05-10T10:00:00.000Z"
 *               meetingAddress:
 *                 type: string
 *                 example: "Rua das Flores, 123, Centro"
 *     responses:
 *       201:
 *         description: Solicitação criada com sucesso
 *       400:
 *         description: Dados inválidos ou agendamento com menos de 2h de antecedência
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas donos podem criar solicitações
 *       409:
 *         description: Pet já possui solicitação ativa
 */
router.post('/', authenticate, requireOwner, validate(createServiceRequestSchema), serviceRequestsController.create);

/**
 * @swagger
 * /service-requests:
 *   get:
 *     summary: Listar solicitações abertas (apenas cuidadores)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Lista de solicitações com status OPEN
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id: { type: string }
 *                       serviceType: { type: string }
 *                       scheduledAt: { type: string, format: date-time }
 *                       meetingAddress: { type: string }
 *                       status: { type: string }
 *                       petId: { type: string }
 *                       ownerId: { type: string }
 *                       expiresAt: { type: string, format: date-time }
 *                       createdAt: { type: string, format: date-time }
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas cuidadores podem listar solicitações abertas
 */
router.get('/', authenticate, requireCaregiver, serviceRequestsController.findOpen);

/**
 * @swagger
 * /service-requests/my:
 *   get:
 *     summary: Listar solicitações do usuário autenticado (dono ou cuidador)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Lista de solicitações do usuário
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id: { type: string }
 *                       serviceType: { type: string }
 *                       scheduledAt: { type: string, format: date-time }
 *                       meetingAddress: { type: string }
 *                       status: { type: string }
 *                       petId: { type: string }
 *                       ownerId: { type: string }
 *                       caregiverId: { type: string }
 *                       expiresAt: { type: string, format: date-time }
 *                       createdAt: { type: string, format: date-time }
 *       401:
 *         description: Token ausente ou inválido
 */
router.get('/my', authenticate, serviceRequestsController.findMine);

/**
 * @swagger
 * /service-requests/{id}:
 *   get:
 *     summary: Buscar solicitação por ID
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID da solicitação
 *     responses:
 *       200:
 *         description: Solicitação encontrada
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: object
 *                   properties:
 *                     id: { type: string }
 *                     serviceType: { type: string }
 *                     scheduledAt: { type: string, format: date-time }
 *                     meetingAddress: { type: string }
 *                     status: { type: string, enum: [OPEN, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED, REFUSED] }
 *                     expiresAt: { type: string, format: date-time }
 *                     createdAt: { type: string, format: date-time }
 *                     pet:
 *                       type: object
 *                       properties:
 *                         id: { type: string }
 *                         name: { type: string }
 *                         species: { type: string }
 *                         breed: { type: string }
 *                     owner:
 *                       type: object
 *                       properties:
 *                         id: { type: string }
 *                         name: { type: string }
 *                         phone: { type: string }
 *                     caregiver:
 *                       type: object
 *                       nullable: true
 *                       properties:
 *                         id: { type: string }
 *                         name: { type: string }
 *                         phone: { type: string }
 *                     review:
 *                       type: object
 *                       nullable: true
 *                       properties:
 *                         id: { type: string }
 *                         rating: { type: integer }
 *                         comment: { type: string }
 *       401:
 *         description: Token ausente ou inválido
 *       404:
 *         description: Solicitação não encontrada
 */
router.get('/:id', authenticate, serviceRequestsController.findById);

/**
 * @swagger
 * /service-requests/{id}/accept:
 *   patch:
 *     summary: Cuidador aceita a solicitação
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID da solicitação
 *     responses:
 *       200:
 *         description: Solicitação aceita, status alterado para ACCEPTED
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Cuidador inativo ou não autorizado
 *       404:
 *         description: Solicitação não encontrada
 *       409:
 *         description: Limite de 3 atendimentos simultâneos atingido
 */
router.patch('/:id/accept', authenticate, requireCaregiver, serviceRequestsController.accept);

/**
 * @swagger
 * /service-requests/{id}/refuse:
 *   patch:
 *     summary: Cuidador recusa a solicitação (volta para OPEN)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID da solicitação
 *     responses:
 *       200:
 *         description: Solicitação recusada, status volta para OPEN
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas cuidadores podem recusar
 *       404:
 *         description: Solicitação não encontrada
 */
router.patch('/:id/refuse', authenticate, requireCaregiver, serviceRequestsController.refuse);

/**
 * @swagger
 * /service-requests/{id}/cancel:
 *   patch:
 *     summary: Dono cancela a solicitação (apenas se OPEN)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID da solicitação
 *     responses:
 *       200:
 *         description: Solicitação cancelada
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Solicitação não pode ser cancelada neste status
 *       404:
 *         description: Solicitação não encontrada
 */
router.patch('/:id/cancel', authenticate, requireOwner, serviceRequestsController.cancel);

/**
 * @swagger
 * /service-requests/{id}/start:
 *   patch:
 *     summary: Cuidador inicia o serviço (ACCEPTED → IN_PROGRESS)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID da solicitação
 *     responses:
 *       200:
 *         description: Serviço iniciado, status alterado para IN_PROGRESS
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas o cuidador atribuído pode iniciar o serviço
 *       404:
 *         description: Solicitação não encontrada
 */
router.patch('/:id/start', authenticate, requireCaregiver, serviceRequestsController.start);

/**
 * @swagger
 * /service-requests/{id}/complete:
 *   patch:
 *     summary: Cuidador conclui o serviço (IN_PROGRESS → COMPLETED)
 *     tags: [ServiceRequests]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID da solicitação
 *     responses:
 *       200:
 *         description: Serviço concluído
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas o cuidador atribuído pode concluir o serviço
 *       404:
 *         description: Solicitação não encontrada
 */
router.patch('/:id/complete', authenticate, requireCaregiver, serviceRequestsController.complete);

module.exports = router;
