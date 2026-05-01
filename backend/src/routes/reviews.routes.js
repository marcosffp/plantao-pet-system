'use strict';

const { Router } = require('express');
const reviewsController = require('../controllers/reviews.controller');
const { authenticate, requireOwner } = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const { createReviewSchema } = require('../schemas/review.schema');

const router = Router();

/**
 * @swagger
 * /reviews:
 *   post:
 *     summary: Criar avaliação do cuidador (apenas donos, serviço deve estar COMPLETED)
 *     tags: [Reviews]
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [serviceRequestId, rating, comment]
 *             properties:
 *               serviceRequestId:
 *                 type: string
 *                 format: uuid
 *                 example: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 example: 5
 *               comment:
 *                 type: string
 *                 example: "Excelente cuidador, muito atencioso com o Rex!"
 *     responses:
 *       201:
 *         description: Avaliação criada e média do cuidador recalculada
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: object
 *                   properties:
 *                     id: { type: string }
 *                     serviceRequestId: { type: string }
 *                     ownerId: { type: string }
 *                     caregiverId: { type: string }
 *                     rating: { type: integer }
 *                     comment: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *       400:
 *         description: Serviço ainda não foi concluído
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Apenas donos podem avaliar
 *       404:
 *         description: Solicitação não encontrada
 *       409:
 *         description: Esta solicitação já foi avaliada
 */
router.post('/', authenticate, requireOwner, validate(createReviewSchema), reviewsController.create);

module.exports = router;
