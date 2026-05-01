'use strict';

const { Router } = require('express');
const ownersController = require('../controllers/owners.controller');
const { authenticate } = require('../middlewares/auth.middleware');

const router = Router();

/**
 * @swagger
 * /owners/{id}:
 *   get:
 *     summary: Buscar dono por ID
 *     tags: [Owners]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do dono
 *     responses:
 *       200:
 *         description: Dono encontrado
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
 *                     address: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *       401:
 *         description: Token ausente ou inválido
 *       404:
 *         description: Dono não encontrado
 */
router.get('/:id', authenticate, ownersController.findById);

module.exports = router;
