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
 */
router.get('/:id', authenticate, ownersController.findById);

module.exports = router;
