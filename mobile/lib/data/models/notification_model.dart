class AppNotification {
  final String id;
  final String userId;
  final String userRole;
  final String eventType;
  final Map<String, dynamic> payload;
  final String? requestId;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.eventType,
    required this.payload,
    this.requestId,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  String get title {
    switch (eventType) {
      case 'service_request.created':
        return 'Nova solicitação de serviço';
      case 'service_request.accepted':
        return 'Solicitação aceita!';
      case 'service_request.refused':
        return 'Solicitação recusada';
      case 'service_request.cancelled':
        return 'Solicitação cancelada';
      case 'service_request.in_progress':
        return 'Serviço iniciado!';
      case 'service.completed':
        return 'Serviço concluído!';
      case 'review.created':
        return 'Nova avaliação recebida!';
      default:
        return 'Notificação';
    }
  }

  String get body {
    switch (eventType) {
      case 'service_request.created':
        return 'Um dono de pet abriu uma nova solicitação de ${payload['serviceType'] ?? ''}.';
      case 'service_request.accepted':
        return '${payload['caregiverName'] ?? 'Um cuidador'} aceitou sua solicitação.';
      case 'service_request.refused':
        return 'Sua solicitação voltou para aberta.';
      case 'service_request.cancelled':
        return 'O dono cancelou a solicitação.';
      case 'service_request.in_progress':
        return 'O cuidador iniciou o serviço.';
      case 'service.completed':
        return 'O serviço foi concluído com sucesso!';
      case 'review.created':
        return 'Você recebeu uma nova avaliação.';
      default:
        return '';
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userRole: json['userRole'] as String,
      eventType: json['eventType'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      requestId: json['requestId'] as String?,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
