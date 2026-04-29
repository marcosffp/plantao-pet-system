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
 *     summary: Criar avaliação do cuidador
 *     tags: [Reviews]
 *     security: [{ bearerAuth: [] }]
 */
router.post('/', authenticate, requireOwner, validate(createReviewSchema), reviewsController.create);

module.exports = router;
