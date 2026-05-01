'use strict';

const notificationsRepo = require('../repositories/notifications.repository');
const AppError = require('../utils/AppError');

const list = (user, unreadOnly) => {
  if (unreadOnly) return notificationsRepo.findUnreadByUser(user.id);
  return notificationsRepo.findAllByUser(user.id);
};

const markRead = async (id, user) => {
  const notification = await notificationsRepo.findById(id);
  if (!notification) throw new AppError(404, 'Notificação não encontrada');
  if (notification.userId !== user.id) throw new AppError(403, 'Acesso negado');
  return notificationsRepo.markRead(id, user.id);
};

module.exports = { list, markRead };
