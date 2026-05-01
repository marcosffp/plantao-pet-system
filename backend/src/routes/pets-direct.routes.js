'use strict';

const { Router } = require('express');
const petsController = require('../controllers/pets.controller');
const { authenticate } = require('../middlewares/auth.middleware');

const router = Router();

/**
 * @swagger
 * /pets/{id}:
 *   get:
 *     summary: Buscar pet por ID
 *     tags: [Pets]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do pet
 *     responses:
 *       200:
 *         description: Pet encontrado
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
 *                     species: { type: string, enum: [DOG, CAT, OTHER] }
 *                     breed: { type: string }
 *                     age: { type: integer }
 *                     specialNotes: { type: string }
 *                     ownerId: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *       401:
 *         description: Token ausente ou inválido
 *       404:
 *         description: Pet não encontrado
 */
router.get('/:id', authenticate, petsController.findById);

module.exports = router;
