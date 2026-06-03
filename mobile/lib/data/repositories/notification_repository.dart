import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final String _base = AppConstants.baseUrl;

  Future<List<AppNotification>> getAll(String token) async {
    final res = await http.get(
      Uri.parse('$_base/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar notificações');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id, String token) async {
    await http.patch(
      Uri.parse('$_base/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
