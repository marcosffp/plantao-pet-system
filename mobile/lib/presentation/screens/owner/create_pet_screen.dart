import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/pet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';

class CreatePetScreen extends StatefulWidget {
  final Pet? pet;

  const CreatePetScreen({super.key, this.pet});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late String _species;

  bool get _isEditing => widget.pet != null;

  static final _speciesOptions = [
    ('DOG', 'Cão'),
    ('CAT', 'Gato'),
    ('OTHER', 'Outro'),
  ];

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    if (pet != null) {
      _nameCtrl.text = pet.name;
      _breedCtrl.text = pet.breed;
      _ageCtrl.text = pet.age.toString();
      _notesCtrl.text = pet.specialNotes ?? '';
      _species = pet.species;
    } else {
      _species = 'DOG';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final provider = context.read<PetProvider>();
    final notes = _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null;

    bool ok;
    if (_isEditing) {
      ok = await provider.update(
        petId: widget.pet!.id,
        token: auth.user!.token,
        name: _nameCtrl.text.trim(),
        species: _species,
        breed: _breedCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        specialNotes: notes,
      );
    } else {
      ok = await provider.create(
        ownerId: auth.user!.id,
        token: auth.user!.token,
        name: _nameCtrl.text.trim(),
        species: _species,
        breed: _breedCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        specialNotes: notes,
      );
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      final err = context.read<PetProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? (_isEditing ? 'Erro ao editar pet' : 'Erro ao cadastrar pet')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Pet' : 'Novo Pet'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('ESPÉCIE'),
              const SizedBox(height: 10),
              Row(
                children: _speciesOptions.map((opt) {
                  final selected = _species == opt.$1;
                  final color = AppConstants.speciesColor(opt.$1);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _species = opt.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.divider,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selected
                                    ? color.withOpacity(0.15)
                                    : AppColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: AppConstants.speciesIconWidget(
                                opt.$1,
                                size: 18,
                                color: selected ? color : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              opt.$2,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight:
                                    selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _sectionLabel('NOME DO PET'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Ex: Rex, Luna'),
                validator: (v) => v == null || v.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('RAÇA'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _breedCtrl,
                decoration: const InputDecoration(hintText: 'Ex: Golden Retriever'),
                validator: (v) => v == null || v.isEmpty ? 'Raça obrigatória' : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('IDADE (anos)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Ex: 3'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Idade obrigatória';
                  final n = int.tryParse(v);
                  if (n == null || n < 0 || n > 30) return 'Idade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _sectionLabel('OBSERVAÇÕES ESPECIAIS (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Alergias, medicamentos, comportamento...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: petProvider.loading ? null : _save,
                  child: petProvider.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Salvar alterações' : 'Cadastrar Pet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      );
}
