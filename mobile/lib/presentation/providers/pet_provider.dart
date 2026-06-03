import 'package:flutter/material.dart';
import '../../data/models/pet_model.dart';
import '../../data/repositories/pet_repository.dart';

class PetProvider extends ChangeNotifier {
  final PetRepository _repo;

  List<Pet> _pets = [];
  bool _loading = false;
  String? _error;

  PetProvider(this._repo);

  List<Pet> get pets => _pets;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load(String ownerId, String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _pets = await _repo.getPets(ownerId, token);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String ownerId,
    required String token,
    required String name,
    required String species,
    required String breed,
    required int age,
    String? specialNotes,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pet = await _repo.createPet(
        ownerId: ownerId,
        token: token,
        name: name,
        species: species,
        breed: breed,
        age: age,
        specialNotes: specialNotes,
      );
      _pets = [pet, ..._pets];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> update({
    required String petId,
    required String token,
    required String name,
    required String species,
    required String breed,
    required int age,
    String? specialNotes,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _repo.updatePet(
        petId: petId,
        token: token,
        name: name,
        species: species,
        breed: breed,
        age: age,
        specialNotes: specialNotes,
      );
      _pets = _pets.map((p) => p.id == petId ? updated : p).toList();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> delete({required String petId, required String token}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deletePet(petId: petId, token: token);
      _pets = _pets.where((p) => p.id != petId).toList();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
