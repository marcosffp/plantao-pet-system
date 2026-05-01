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
 *             required: [name, email, phone, address, password]
 *             properties:
 *               name:
 *                 type: string
 *                 example: João Silva
 *               email:
 *                 type: string
 *                 format: email
 *                 example: joao@email.com
 *               phone:
 *                 type: string
 *                 example: "11999990000"
 *               address:
 *                 type: string
 *                 example: Rua das Flores, 123, Centro
 *               password:
 *                 type: string
 *                 minLength: 6
 *                 example: senha123
 *     responses:
 *       201:
 *         description: Dono cadastrado — token JWT já incluído na resposta
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
 *                     email: { type: string }
 *                     phone: { type: string }
 *                     address: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *                     token: { type: string }
 *       409:
 *         description: Email ou telefone já cadastrado
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
 *             required: [email, password]
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: joao@email.com
 *               password:
 *                 type: string
 *                 example: senha123
 *     responses:
 *       200:
 *         description: Token JWT retornado
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token: { type: string }
 *       401:
 *         description: Credenciais inválidas
 */
router.post('/owner/login', validate(loginSchema), authController.loginOwner);

/**
 * @swagger
 * /auth/caregiver/register:
 *   post:
 *     summary: Cadastrar novo cuidador
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email, phone, neighborhoods, services, password]
 *             properties:
 *               name:
 *                 type: string
 *                 example: Maria Cuidadora
 *               email:
 *                 type: string
 *                 format: email
 *                 example: maria@email.com
 *               phone:
 *                 type: string
 *                 example: "11988880000"
 *               neighborhoods:
 *                 type: array
 *                 items: { type: string }
 *                 example: ["Centro", "Vila Madalena"]
 *               services:
 *                 type: array
 *                 items:
 *                   type: string
 *                   enum: [WALK_30MIN, WALK_1H, HOME_VISIT, HOSTING]
 *                 example: ["WALK_30MIN", "HOME_VISIT"]
 *               password:
 *                 type: string
 *                 minLength: 6
 *                 example: senha123
 *     responses:
 *       201:
 *         description: Cuidador cadastrado — token JWT já incluído na resposta
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
 *                     email: { type: string }
 *                     phone: { type: string }
 *                     neighborhoods: { type: array, items: { type: string } }
 *                     services: { type: array, items: { type: string } }
 *                     averageRating: { type: number }
 *                     status: { type: string }
 *                     createdAt: { type: string, format: date-time }
 *                     token: { type: string }
 *       409:
 *         description: Email ou telefone já cadastrado
 */
router.post('/caregiver/register', validate(registerCaregiverSchema), authController.registerCaregiver);

/**
 * @swagger
 * /auth/caregiver/login:
 *   post:
 *     summary: Login do cuidador
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: maria@email.com
 *               password:
 *                 type: string
 *                 example: senha123
 *     responses:
 *       200:
 *         description: Token JWT retornado
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token: { type: string }
 *       401:
 *         description: Credenciais inválidas
 */
router.post('/caregiver/login', validate(loginCaregiverSchema), authController.loginCaregiver);

module.exports = router;
