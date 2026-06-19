import 'package:flutter/material.dart';
import '../../core/utils/token_storage.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final SocketService _socket;

  AuthUser? _user;
  bool _loading = false;
  String? _error;

  AuthProvider(this._repo, this._socket);

  AuthUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> tryAutoLogin() async {
    final token = await TokenStorage.getToken();
    final userData = await TokenStorage.getUser();
    if (token == null || userData == null) return;
    _user = AuthUser.fromJson(userData, userData['role'] as String, token);
    _socket.connect(token);
    notifyListeners();
  }

  Future<bool> loginOwner(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.loginOwner(email, password);
      await TokenStorage.saveToken(_user!.token);
      await TokenStorage.saveUser(_user!.toJson());
      _socket.connect(_user!.token);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> loginCaregiver(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.loginCaregiver(email, password);
      await TokenStorage.saveToken(_user!.token);
      await TokenStorage.saveUser(_user!.toJson());
      _socket.connect(_user!.token);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> registerOwner({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.registerOwner(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
      );
      await TokenStorage.saveToken(_user!.token);
      await TokenStorage.saveUser(_user!.toJson());
      _socket.connect(_user!.token);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> registerCaregiver({
    required String name,
    required String email,
    required String phone,
    required List<String> neighborhoods,
    required List<String> services,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.registerCaregiver(
        name: name,
        email: email,
        phone: phone,
        neighborhoods: neighborhoods,
        services: services,
        password: password,
      );
      await TokenStorage.saveToken(_user!.token);
      await TokenStorage.saveUser(_user!.toJson());
      _socket.connect(_user!.token);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    if (_user == null || _user!.role != 'caregiver') return;
    try {
      final refreshed = await _repo.fetchCaregiverProfile(_user!.id, _user!.token);
      _user = refreshed;
      await TokenStorage.saveUser(_user!.toJson());
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateCaregiverStatus(String status) async {
    if (_user == null) return false;
    _loading = true;
    notifyListeners();
    try {
      await _repo.updateCaregiverStatus(status, _user!.token);
      _user = AuthUser(
        id: _user!.id,
        role: _user!.role,
        name: _user!.name,
        email: _user!.email,
        phone: _user!.phone,
        token: _user!.token,
        address: _user!.address,
        neighborhoods: _user!.neighborhoods,
        services: _user!.services,
        averageRating: _user!.averageRating,
        status: status,
      );
      await TokenStorage.saveUser(_user!.toJson());
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _socket.disconnect();
    await TokenStorage.clear();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
