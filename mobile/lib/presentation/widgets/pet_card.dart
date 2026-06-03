import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pet_model.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PetCard({super.key, required this.pet, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final emoji = AppConstants.speciesEmoji[pet.species] ?? '🐾';
    final speciesLabel = AppConstants.speciesLabels[pet.species] ?? pet.species;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${pet.breed} · ${pet.age} ${pet.age == 1 ? 'ano' : 'anos'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _SpeciesChip(label: speciesLabel, species: pet.species),
                    if (pet.specialNotes != null && pet.specialNotes!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _NoteChip(text: pet.specialNotes!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            ),
        ],
      ),
    );
  }
}

class _SpeciesChip extends StatelessWidget {
  final String label;
  final String species;

  const _SpeciesChip({required this.label, required this.species});

  Color get _color {
    switch (species) {
      case 'DOG':
        return AppColors.primary;
      case 'CAT':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  final String text;

  const _NoteChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
