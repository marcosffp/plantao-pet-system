import 'package:flutter/material.dart';
import '../../data/models/service_request_model.dart';
import '../../data/repositories/service_request_repository.dart';
import '../../services/socket_service.dart';

class ServiceRequestProvider extends ChangeNotifier {
  final ServiceRequestRepository _repo;
  final SocketService _socket;

  List<ServiceRequest> _requests = [];
  List<ServiceRequest> _openRequests = [];
  bool _loading = false;
  String? _error;

  ServiceRequestProvider(this._repo, this._socket);

  List<ServiceRequest> get requests => _requests;
  List<ServiceRequest> get openRequests => _openRequests;
  bool get loading => _loading;
  String? get error => _error;

  void listenToSocket(String token) {
    _socket.on('new_request', (_) => loadOpen(token));
    _socket.on('request_accepted', (_) => loadMine(token));
    _socket.on('request_refused', (_) => loadMine(token));
    _socket.on('service_started', (_) => loadMine(token));
    _socket.on('service_completed', (_) => loadMine(token));
  }

  Future<void> loadMine(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _requests = await _repo.getMine(token);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadOpen(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _openRequests = await _repo.getOpen(token);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String token,
    required String petId,
    required String serviceType,
    required DateTime scheduledAt,
    required String meetingAddress,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final req = await _repo.create(
        token: token,
        petId: petId,
        serviceType: serviceType,
        scheduledAt: scheduledAt.toUtc().toIso8601String(),
        meetingAddress: meetingAddress,
      );
      _requests = [req, ..._requests];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> accept(String id, String token) async {
    try {
      final updated = await _repo.accept(id, token);
      _openRequests.removeWhere((r) => r.id == updated.id);
      _updateInMine(updated);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> refuse(String id, String token) async {
    try {
      await _repo.refuse(id, token);
      _openRequests.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancel(String id, String token) async {
    try {
      final updated = await _repo.cancel(id, token);
      _updateInMine(updated);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> start(String id, String token) async {
    try {
      final updated = await _repo.start(id, token);
      _updateInMine(updated);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> complete(String id, String token) async {
    try {
      final updated = await _repo.complete(id, token);
      _updateInMine(updated);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _updateInMine(ServiceRequest updated) {
    final idx = _requests.indexWhere((r) => r.id == updated.id);
    if (idx >= 0) {
      _requests[idx] = updated;
    } else {
      _requests = [updated, ..._requests];
    }
    notifyListeners();
  }

  void _updateInOpen(ServiceRequest updated) {
    _openRequests.removeWhere((r) => r.id == updated.id);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
