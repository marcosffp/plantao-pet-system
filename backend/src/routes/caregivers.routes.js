'use strict';

const { Router } = require('express');
const caregiversController = require('../controllers/caregivers.controller');
const { authenticate, requireCaregiver } = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const { updateStatusSchema } = require('../schemas/caregiver.schema');

const router = Router();

/**
 * @swagger
 * /caregivers:
 *   get:
 *     summary: Listar cuidadores ativos
 *     tags: [Caregivers]
 *     responses:
 *       200:
 *         description: Lista de cuidadores com status ACTIVE
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
 *                       name: { type: string }
 *                       phone: { type: string }
 *                       neighborhoods: { type: array, items: { type: string } }
 *                       services: { type: array, items: { type: string } }
 *                       averageRating: { type: number }
 *                       status: { type: string }
 *                       createdAt: { type: string, format: date-time }
 */
router.get('/', caregiversController.findAll);

/**
 * @swagger
 * /caregivers/{id}:
 *   get:
 *     summary: Buscar cuidador por ID
 *     tags: [Caregivers]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do cuidador
 *     responses:
 *       200:
 *         description: Cuidador encontrado
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: object
 *                   properties:
 *                     id: { type: string }
 *                     name: { type: string }
 *                     phone: { type: string }
 *                     neighborhoods: { type: array, items: { type: string } }
 *                     services: { type: array, items: { type: string } }
 *                     averageRating: { type: number }
 *                     status: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *       404:
 *         description: Cuidador não encontrado
 */
router.get('/:id', caregiversController.findById);

/**
 * @swagger
 * /caregivers/{id}/status:
 *   patch:
 *     summary: Atualizar status do cuidador (ACTIVE ou INACTIVE)
 *     tags: [Caregivers]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do cuidador
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [status]
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [ACTIVE, INACTIVE]
 *                 example: INACTIVE
 *     responses:
 *       200:
 *         description: Status atualizado
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: object
 *       400:
 *         description: Status inválido
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas cuidadores podem alterar o próprio status
 */
router.patch('/:id/status', authenticate, requireCaregiver, validate(updateStatusSchema), caregiversController.updateStatus);

/**
 * @swagger
 * /caregivers/{id}/reviews:
 *   get:
 *     summary: Listar avaliações do cuidador
 *     tags: [Caregivers]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do cuidador
 *     responses:
 *       200:
 *         description: Lista de avaliações
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
 *                       rating: { type: integer }
 *                       comment: { type: string }
 *                       ownerId: { type: string }
 *                       caregiverId: { type: string }
 *                       createdAt: { type: string, format: date-time }
 *       404:
 *         description: Cuidador não encontrado
 */
router.get('/:id/reviews', caregiversController.findReviews);

module.exports = router;
