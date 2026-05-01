'use strict';

const { Router } = require('express');
const notificationsController = require('../controllers/notifications.controller');
const { authenticate } = require('../middlewares/auth.middleware');

const router = Router();

/**
 * @swagger
 * /notifications:
 *   get:
 *     summary: Listar notificações do usuário autenticado
 *     tags: [Notifications]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: query
 *         name: unread
 *         schema:
 *           type: boolean
 *         description: Se true, retorna apenas não lidas
 *     responses:
 *       200:
 *         description: Lista de notificações
 */
router.get('/', authenticate, notificationsController.list);

/**
 * @swagger
 * /notifications/{id}/read:
 *   patch:
 *     summary: Marcar notificação como lida
 *     tags: [Notifications]
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Notificação marcada como lida
 *       403:
 *         description: Acesso negado
 *       404:
 *         description: Notificação não encontrada
 */
router.patch('/:id/read', authenticate, notificationsController.markRead);

module.exports = router;
