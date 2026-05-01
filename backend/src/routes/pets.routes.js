'use strict';

const { Router } = require('express');
const petsController = require('../controllers/pets.controller');
const { authenticate, requireOwner } = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const { createPetSchema } = require('../schemas/pet.schema');

const router = Router();

/**
 * @swagger
 * /owners/{ownerId}/pets:
 *   post:
 *     summary: Cadastrar pet para o dono
 *     tags: [Pets]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: ownerId
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do dono
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, species, breed, age]
 *             properties:
 *               name:
 *                 type: string
 *                 example: Rex
 *               species:
 *                 type: string
 *                 enum: [DOG, CAT, OTHER]
 *                 example: DOG
 *               breed:
 *                 type: string
 *                 example: Labrador
 *               age:
 *                 type: integer
 *                 example: 3
 *               specialNotes:
 *                 type: string
 *                 example: Alérgico a frango
 *     responses:
 *       201:
 *         description: Pet cadastrado com sucesso
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
 *                     species: { type: string }
 *                     breed: { type: string }
 *                     age: { type: integer }
 *                     specialNotes: { type: string }
 *                     ownerId: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Acesso negado
 */
router.post('/:ownerId/pets', authenticate, requireOwner, validate(createPetSchema), petsController.create);

/**
 * @swagger
 * /owners/{ownerId}/pets:
 *   get:
 *     summary: Listar pets do dono
 *     tags: [Pets]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: ownerId
 *         required: true
 *         schema: { type: string, format: uuid }
 *         description: ID do dono
 *     responses:
 *       200:
 *         description: Lista de pets
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
 *                       species: { type: string }
 *                       breed: { type: string }
 *                       age: { type: integer }
 *                       specialNotes: { type: string }
 *                       ownerId: { type: string }
 *                       createdAt: { type: string, format: date-time }
 *       401:
 *         description: Token ausente ou inválido
 */
router.get('/:ownerId/pets', authenticate, petsController.findByOwnerId);

module.exports = router;
