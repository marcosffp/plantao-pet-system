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
 */
router.get('/:id', authenticate, petsController.findById);

module.exports = router;
