import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/utils/token_storage.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final String _base = AppConstants.baseUrl;

  Future<AuthUser> loginOwner(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/owner/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Erro ao fazer login');
    }
    final token = body['token'] as String;
    final profileRes = await http.get(
      Uri.parse('$_base/owners/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final profileBody = jsonDecode(profileRes.body) as Map<String, dynamic>;
    return AuthUser.fromJson(profileBody['data'] as Map<String, dynamic>, 'owner', token);
  }

  Future<AuthUser> loginCaregiver(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/caregiver/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Erro ao fazer login');
    }
    final token = body['token'] as String;
    final claims = TokenStorage.decodeToken(token)!;
    final profileRes = await http.get(
      Uri.parse('$_base/caregivers/${claims['id']}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final profileBody = jsonDecode(profileRes.body) as Map<String, dynamic>;
    return AuthUser.fromJson(profileBody['data'] as Map<String, dynamic>, 'caregiver', token);
  }

  Future<AuthUser> registerOwner({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/owner/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Erro ao criar conta');
    }
    final data = body['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    return AuthUser.fromJson(data, 'owner', token);
  }

  Future<AuthUser> fetchCaregiverProfile(String caregiverId, String token) async {
    final res = await http.get(
      Uri.parse('$_base/caregivers/$caregiverId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao atualizar perfil');
    }
    return AuthUser.fromJson(body['data'] as Map<String, dynamic>, 'caregiver', token);
  }

  Future<void> updateCaregiverStatus(String status, String token) async {
    final res = await http.patch(
      Uri.parse('$_base/caregivers/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Erro ao atualizar status');
    }
  }

  Future<AuthUser> registerCaregiver({
    required String name,
    required String email,
    required String phone,
    required List<String> neighborhoods,
    required List<String> services,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/caregiver/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'neighborhoods': neighborhoods,
        'services': services,
        'password': password,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Erro ao criar conta');
    }
    final data = body['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    return AuthUser.fromJson(data, 'caregiver', token);
  }
}
