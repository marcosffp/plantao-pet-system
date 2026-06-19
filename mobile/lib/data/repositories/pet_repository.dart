import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/pet_model.dart';

class PetRepository {
  final String _base = AppConstants.baseUrl;

  Future<List<Pet>> getPets(String ownerId, String token) async {
    final res = await http.get(
      Uri.parse('$_base/owners/pets'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar pets');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List;
    return list.map((e) => Pet.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pet> createPet({
    required String ownerId,
    required String token,
    required String name,
    required String species,
    required String breed,
    required int age,
    String? specialNotes,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/owners/pets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        if (specialNotes != null && specialNotes.isNotEmpty) 'specialNotes': specialNotes,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao cadastrar pet');
    }
    return Pet.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Pet> updatePet({
    required String petId,
    required String token,
    required String name,
    required String species,
    required String breed,
    required int age,
    String? specialNotes,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/owners/pets/$petId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'specialNotes': (specialNotes != null && specialNotes.isNotEmpty) ? specialNotes : '',
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao editar pet');
    }
    return Pet.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deletePet({required String petId, required String token}) async {
    final res = await http.delete(
      Uri.parse('$_base/owners/pets/$petId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 204) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? 'Erro ao deletar pet');
    }
  }
}
