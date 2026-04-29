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
 */
router.post('/:ownerId/pets', authenticate, requireOwner, validate(createPetSchema), petsController.create);

/**
 * @swagger
 * /owners/{ownerId}/pets:
 *   get:
 *     summary: Listar pets do dono
 *     tags: [Pets]
 *     security: [{ bearerAuth: [] }]
 */
router.get('/:ownerId/pets', authenticate, petsController.findByOwnerId);

module.exports = router;
