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

  static const Map<String, String> speciesEmoji = {
    'DOG': '🐕',
    'CAT': '🐈',
    'OTHER': '🐾',
  };

  static const Map<String, String> statusLabels = {
    'OPEN': 'Aberta',
    'ACCEPTED': 'Aceita',
    'IN_PROGRESS': 'Em andamento',
    'COMPLETED': 'Concluída',
    'CANCELLED': 'Cancelada',
    'REFUSED': 'Recusada',
  };
}
