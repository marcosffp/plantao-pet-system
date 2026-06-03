import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_request_provider.dart';
import '../../widgets/status_badge.dart';

class CaregiverRequestDetailScreen extends StatelessWidget {
  final ServiceRequest request;

  const CaregiverRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final srProvider = context.watch<ServiceRequestProvider>();
    final req = srProvider.openRequests.firstWhere(
      (r) => r.id == request.id,
      orElse: () => srProvider.requests.firstWhere(
        (r) => r.id == request.id,
        orElse: () => request,
      ),
    );

    final emoji = AppConstants.speciesEmoji[req.pet.species] ?? '🐾';
    final serviceLabel = AppConstants.serviceTypeLabels[req.serviceType] ?? req.serviceType;
    final dateStr = DateFormat('dd/MM/yyyy').format(req.scheduledAt.toLocal());
    final timeStr = DateFormat('HH:mm').format(req.scheduledAt.toLocal());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${req.pet.name} · ${req.pet.breed}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              serviceLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: req.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Detail(
                        icon: Icons.calendar_today_outlined,
                        label: 'Data',
                        value: dateStr,
                      ),
                      const SizedBox(width: 24),
                      _Detail(
                        icon: Icons.access_time,
                        label: 'Horário',
                        value: timeStr,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Detail(
                    icon: Icons.location_on_outlined,
                    label: 'Endereço',
                    value: req.meetingAddress,
                  ),
                  const SizedBox(height: 12),
                  _Detail(
                    icon: Icons.person_outline,
                    label: 'Dono',
                    value: '${req.owner.name} · ${req.owner.phone}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (req.status == 'OPEN') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await srProvider.accept(req.id, auth.user!.token);
                    if (!context.mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solicitação aceita!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(srProvider.error ?? 'Erro ao aceitar'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aceitar Solicitação'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await srProvider.refuse(req.id, auth.user!.token);
                    if (!context.mounted) return;
                    if (ok) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text('Recusar', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                ),
              ),
            ],
            if (req.status == 'ACCEPTED' && req.caregiverId == auth.user?.id) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await srProvider.start(req.id, auth.user!.token);
                    if (!context.mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Serviço iniciado!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(srProvider.error ?? 'Erro ao iniciar'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Iniciar Serviço'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusInProgress),
                ),
              ),
            ],
            if (req.status == 'IN_PROGRESS' && req.caregiverId == auth.user?.id) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Concluir serviço'),
                        content: const Text('Confirmar conclusão do serviço?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Não'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Confirmar'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true || !context.mounted) return;
                    final ok = await srProvider.complete(req.id, auth.user!.token);
                    if (!context.mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Serviço concluído!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(srProvider.error ?? 'Erro ao concluir'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Concluir Serviço'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Detail({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
