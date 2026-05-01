'use strict';

const notificationsService = require('../services/notifications.service');
const asyncHandler = require('../utils/asyncHandler');

const list = asyncHandler(async (req, res) => {
  const unreadOnly = req.query.unread === 'true';
  const data = await notificationsService.list(req.user, unreadOnly);
  res.json({ data });
});

const markRead = asyncHandler(async (req, res) => {
  await notificationsService.markRead(req.params.id, req.user);
  res.json({ message: 'Notificação marcada como lida' });
});

module.exports = { list, markRead };
