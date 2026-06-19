import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/review_model.dart';

class CaregiverSummary {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> neighborhoods;
  final List<String> services;
  final double? averageRating;
  final int? totalReviews;
  final String status;

  const CaregiverSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.neighborhoods,
    required this.services,
    this.averageRating,
    this.totalReviews,
    required this.status,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory CaregiverSummary.fromJson(Map<String, dynamic> json) {
    return CaregiverSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      neighborhoods: json['neighborhoods'] != null
          ? List<String>.from(json['neighborhoods'] as List)
          : [],
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : [],
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      totalReviews: json['totalReviews'] as int?,
      status: json['status'] as String? ?? 'INACTIVE',
    );
  }
}

class CaregiverRepository {
  final String _base = AppConstants.baseUrl;

  Future<List<CaregiverSummary>> getAll(String token) async {
    final res = await http.get(
      Uri.parse('$_base/caregivers'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar cuidadores');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List;
    return list.map((e) => CaregiverSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CaregiverSummary> getById(String id, String token) async {
    final res = await http.get(
      Uri.parse('$_base/caregivers/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar cuidador');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CaregiverSummary.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Review>> getReviews(String id, String token) async {
    final res = await http.get(
      Uri.parse('$_base/caregivers/$id/reviews'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar avaliações');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }
}
