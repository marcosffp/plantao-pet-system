import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../services/socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo;
  final SocketService _socket;

  List<AppNotification> _notifications = [];
  bool _loading = false;

  NotificationProvider(this._repo, this._socket);

  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void listenToSocket(String token) {
    final events = [
      'new_request',
      'request_accepted',
      'request_refused',
      'service_started',
      'service_completed',
      'new_review',
    ];
    for (final event in events) {
      _socket.on(event, (_) => load(token));
    }
  }

  Future<void> load(String token) async {
    _loading = true;
    notifyListeners();
    try {
      _notifications = await _repo.getAll(token);
    } catch (_) {
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id, String token) async {
    await _repo.markRead(id, token);
    _socket.markRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = AppNotification(
        id: _notifications[idx].id,
        userId: _notifications[idx].userId,
        userRole: _notifications[idx].userRole,
        eventType: _notifications[idx].eventType,
        payload: _notifications[idx].payload,
        requestId: _notifications[idx].requestId,
        readAt: DateTime.now(),
        createdAt: _notifications[idx].createdAt,
      );
      notifyListeners();
    }
  }
}
