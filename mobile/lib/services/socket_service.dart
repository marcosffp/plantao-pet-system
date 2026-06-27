import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/app_constants.dart';

class SocketService {
  io.Socket? _socket;
  final Map<String, List<Function(dynamic)>> _listeners = {};

  void connect(String token) {
    disconnect();
    _socket = io.io(
      AppConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _listeners['connect']?.forEach((fn) => fn(null));
    });

    _socket!.onDisconnect((_) {
      _listeners['disconnect']?.forEach((fn) => fn(null));
    });

    _socket!.onError((err) {
      _listeners['error']?.forEach((fn) => fn(err));
    });

    final events = [
      'new_request',
      'request_accepted',
      'request_refused',
      'request_cancelled',
      'service_started',
      'service_completed',
      'new_review',
    ];

    for (final event in events) {
      _socket!.on(event, (data) {
        _listeners[event]?.forEach((fn) => fn(data));
      });
    }
  }

  void on(String event, Function(dynamic) callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  void off(String event, Function(dynamic) callback) {
    _listeners[event]?.remove(callback);
  }

  void markRead(String notificationId) {
    _socket?.emit('mark_read', notificationId);
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _listeners.clear();
  }

  bool get isConnected => _socket?.connected ?? false;
}
