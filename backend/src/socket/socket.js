'use strict';

const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const notificationsRepo = require('../repositories/notifications.repository');

let _io;

const init = (httpServer) => {
  _io = new Server(httpServer, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
  });

  _io.use((socket, next) => {
    const token = socket.handshake.query.token;
    if (!token) return next(new Error('Token não fornecido'));
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.user = { id: decoded.id, role: decoded.role };
      next();
    } catch {
      next(new Error('Token inválido'));
    }
  });

  _io.on('connection', (socket) => {
    const { id, role } = socket.user;
    const room = `${role}:${id}`;
    socket.join(room);
    console.log(`[WS] ${role} ${id} conectado — sala: ${room}`);

    socket.on('mark_read', async (notificationId) => {
      try {
        await notificationsRepo.markRead(notificationId, id);
        console.log(`[WS] Notificação ${notificationId} marcada como lida por ${id}`);
      } catch (err) {
        console.error('[WS] Erro ao marcar notificação como lida:', err.message);
      }
    });

    socket.on('disconnect', () => {
      console.log(`[WS] ${role} ${id} desconectado`);
    });
  });

  console.log('[WS] Socket.io inicializado');
  return _io;
};

const getIo = () => _io;

const emitToUser = (role, userId, event, data) => {
  if (!_io) return;
  _io.to(`${role}:${userId}`).emit(event, data);
};

module.exports = { init, getIo, emitToUser };
