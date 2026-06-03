import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final String _base = AppConstants.baseUrl;

  Future<Review> create({
    required String token,
    required String serviceRequestId,
    required String caregiverId,
    required int rating,
    required String comment,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'serviceRequestId': serviceRequestId,
        'caregiverId': caregiverId,
        'rating': rating,
        'comment': comment,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Erro ao enviar avaliação');
    }
    return Review.fromJson(body['data'] as Map<String, dynamic>);
  }
}
