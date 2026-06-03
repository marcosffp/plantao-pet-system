'use strict';

const { Router } = require('express');
const petsController = require('../controllers/pets.controller');
const { authenticate, requireOwner } = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');
const { createPetSchema, updatePetSchema } = require('../schemas/pet.schema');

const router = Router();

/**
 * @swagger
 * /owners/pets:
 *   post:
 *     summary: Cadastrar pet para o dono autenticado
 *     tags: [Pets]
 *     security: [{ bearerAuth: [] }]
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
 *         description: Acesso restrito a donos
 */
router.post('/pets', authenticate, requireOwner, validate(createPetSchema), petsController.create);

/**
 * @swagger
 * /owners/pets:
 *   get:
 *     summary: Listar pets do dono autenticado
 *     tags: [Pets]
 *     security: [{ bearerAuth: [] }]
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
 *       403:
 *         description: Acesso restrito a donos
 */
router.get('/pets', authenticate, requireOwner, petsController.findMine);

router.put('/pets/:petId', authenticate, requireOwner, validate(updatePetSchema), petsController.update);

router.delete('/pets/:petId', authenticate, requireOwner, petsController.remove);

module.exports = router;
