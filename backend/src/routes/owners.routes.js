'use strict';

const { Router } = require('express');
const ownersController = require('../controllers/owners.controller');
const { authenticate, requireOwner } = require('../middlewares/auth.middleware');

const router = Router();

/**
 * @swagger
 * /owners/me:
 *   get:
 *     summary: Buscar perfil do dono autenticado
 *     tags: [Owners]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Perfil do dono
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
 *       401:
 *         description: Token ausente ou inválido
 *       403:
 *         description: Acesso restrito a donos
 */
router.get('/me', authenticate, requireOwner, ownersController.getMe);

module.exports = router;
