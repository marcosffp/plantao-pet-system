import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Map<String, String> serviceTypeLabels = {
    'WALK_30MIN': 'Passeio 30min',
    'WALK_1H': 'Passeio 1h',
    'HOME_VISIT': 'Visita Domiciliar',
    'HOSTING': 'Hospedagem',
  };

  static const Map<String, String> speciesLabels = {
    'DOG': 'Cão',
    'CAT': 'Gato',
    'OTHER': 'Outro',
  };

  static const Map<String, String> statusLabels = {
    'OPEN': 'Aberta',
    'ACCEPTED': 'Aceita',
    'IN_PROGRESS': 'Em andamento',
    'COMPLETED': 'Concluída',
    'CANCELLED': 'Cancelada',
    'REFUSED': 'Recusada',
  };

  static IconData speciesIcon(String species) {
    switch (species) {
      case 'DOG':
        return Icons.pets;
      default:
        return Icons.help_outline;
    }
  }

  static Widget speciesIconWidget(String species, {required double size, required Color color}) {
    if (species == 'CAT') {
      return Center(child: FaIcon(FontAwesomeIcons.cat, size: size, color: color));
    }
    return Icon(speciesIcon(species), size: size, color: color);
  }

  static Color speciesColor(String species) {
    switch (species) {
      case 'DOG':
        return AppColors.primary;
      case 'CAT':
        return AppColors.speciesCat;
      default:
        return AppColors.textSecondary;
    }
  }
}
