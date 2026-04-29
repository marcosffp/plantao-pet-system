'use strict';

const { Router } = require('express');
const authController = require('../controllers/auth.controller');
const validate = require('../middlewares/validate.middleware');
const { registerOwnerSchema, loginSchema } = require('../schemas/owner.schema');
const { registerCaregiverSchema, loginCaregiverSchema } = require('../schemas/caregiver.schema');

const router = Router();

/**
 * @swagger
 * /auth/owner/register:
 *   post:
 *     summary: Cadastrar novo dono
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, phone, address, password]
 *             properties:
 *               name: { type: string }
 *               phone: { type: string }
 *               address: { type: string }
 *               password: { type: string }
 *     responses:
 *       201:
 *         description: Dono criado com sucesso
 */
router.post('/owner/register', validate(registerOwnerSchema), authController.registerOwner);

/**
 * @swagger
 * /auth/owner/login:
 *   post:
 *     summary: Login do dono
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [phone, password]
 *             properties:
 *               phone: { type: string }
 *               password: { type: string }
 *     responses:
 *       200:
 *         description: Token JWT retornado
 */
router.post('/owner/login', validate(loginSchema), authController.loginOwner);

/**
 * @swagger
 * /auth/caregiver/register:
 *   post:
 *     summary: Cadastrar novo cuidador
 *     tags: [Auth]
 */
router.post('/caregiver/register', validate(registerCaregiverSchema), authController.registerCaregiver);

/**
 * @swagger
 * /auth/caregiver/login:
 *   post:
 *     summary: Login do cuidador
 *     tags: [Auth]
 */
router.post('/caregiver/login', validate(loginCaregiverSchema), authController.loginCaregiver);

module.exports = router;
