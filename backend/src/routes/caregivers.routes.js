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
 */
router.get('/', caregiversController.findAll);

/**
 * @swagger
 * /caregivers/{id}:
 *   get:
 *     summary: Buscar cuidador por ID
 *     tags: [Caregivers]
 */
router.get('/:id', caregiversController.findById);

/**
 * @swagger
 * /caregivers/{id}/status:
 *   patch:
 *     summary: Atualizar status do cuidador
 *     tags: [Caregivers]
 *     security: [{ bearerAuth: [] }]
 */
router.patch('/:id/status', authenticate, requireCaregiver, validate(updateStatusSchema), caregiversController.updateStatus);

/**
 * @swagger
 * /caregivers/{id}/reviews:
 *   get:
 *     summary: Listar avaliações do cuidador
 *     tags: [Caregivers]
 */
router.get('/:id/reviews', caregiversController.findReviews);

module.exports = router;
