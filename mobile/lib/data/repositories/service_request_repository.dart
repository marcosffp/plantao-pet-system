import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/service_request_model.dart';

class ServiceRequestRepository {
  final String _base = AppConstants.baseUrl;

  Future<List<ServiceRequest>> getMine(String token) async {
    final res = await http.get(
      Uri.parse('$_base/service-requests/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar solicitações');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List;
    return list.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceRequest>> getOpen(String token) async {
    final res = await http.get(
      Uri.parse('$_base/service-requests'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar solicitações abertas');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List;
    return list.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ServiceRequest> getById(String id, String token) async {
    final res = await http.get(
      Uri.parse('$_base/service-requests/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Solicitação não encontrada');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ServiceRequest> create({
    required String token,
    required String petId,
    required String serviceType,
    required String scheduledAt,
    required String meetingAddress,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/service-requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'petId': petId,
        'serviceType': serviceType,
        'scheduledAt': scheduledAt,
        'meetingAddress': meetingAddress,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao criar solicitação');
    }
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ServiceRequest> accept(String id, String token) async {
    final res = await http.patch(
      Uri.parse('$_base/service-requests/$id/accept'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao aceitar solicitação');
    }
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ServiceRequest> refuse(String id, String token) async {
    final res = await http.patch(
      Uri.parse('$_base/service-requests/$id/refuse'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao recusar solicitação');
    }
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ServiceRequest> cancel(String id, String token) async {
    final res = await http.patch(
      Uri.parse('$_base/service-requests/$id/cancel'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao cancelar solicitação');
    }
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ServiceRequest> start(String id, String token) async {
    final res = await http.patch(
      Uri.parse('$_base/service-requests/$id/start'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao iniciar serviço');
    }
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ServiceRequest> complete(String id, String token) async {
    final res = await http.patch(
      Uri.parse('$_base/service-requests/$id/complete'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao concluir serviço');
    }
    return ServiceRequest.fromJson(body['data'] as Map<String, dynamic>);
  }
}
