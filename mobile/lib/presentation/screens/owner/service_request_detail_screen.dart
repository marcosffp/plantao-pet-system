import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_request_provider.dart';
import '../../widgets/status_badge.dart';
import 'review_screen.dart';

class ServiceRequestDetailScreen extends StatefulWidget {
  final ServiceRequest request;

  const ServiceRequestDetailScreen({super.key, required this.request});

  @override
  State<ServiceRequestDetailScreen> createState() => _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState extends State<ServiceRequestDetailScreen> {
  late ServiceRequest _request;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar solicitação'),
        content: const Text('Tem certeza que deseja cancelar esta solicitação?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final auth = context.read<AuthProvider>();
    final ok = await context.read<ServiceRequestProvider>().cancel(_request.id, auth.user!.token);
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final srProvider = context.watch<ServiceRequestProvider>();
    final req = srProvider.requests.firstWhere(
      (r) => r.id == _request.id,
      orElse: () => _request,
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
        actions: [
          if (req.status == 'OPEN')
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'cancel') _cancel();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancelar solicitação', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
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
                              req.pet.name,
                              style: const TextStyle(
                                fontSize: 18,
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
                      _InfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Data',
                        value: dateStr,
                      ),
                      const SizedBox(width: 24),
                      _InfoItem(
                        icon: Icons.access_time,
                        label: 'Horário',
                        value: timeStr,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Endereço',
                    value: req.meetingAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (req.status == 'IN_PROGRESS' && req.caregiver != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk, color: AppColors.statusInProgress, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${req.pet.name} está em passeio agora com ${req.caregiver!.name}',
                        style: const TextStyle(
                          color: AppColors.statusInProgress,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (req.caregiver != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          req.caregiver!.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.caregiver!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                req.caregiver!.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _ProgressTimeline(request: req),
            if (req.status == 'COMPLETED' && req.review == null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(request: req),
                    ),
                  ),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Avaliar Cuidador'),
                ),
              ),
            ],
            if (req.review != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('SUA AVALIAÇÃO', style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        )),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < req.review!.rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      req.review!.comment,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ],
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({required this.icon, required this.label, required this.value});

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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  final ServiceRequest request;

  const _ProgressTimeline({required this.request});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Solicitação criada', true, request.createdAt),
      ('Solicitação aceita', request.caregiver != null, null),
      ('Serviço iniciado', request.status == 'IN_PROGRESS' || request.status == 'COMPLETED', null),
      ('Serviço concluído', request.status == 'COMPLETED', null),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESSO DO ATENDIMENTO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            final isLast = i == steps.length - 1;
            final done = step.$2;
            final isActive = done && !isLast;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done ? AppColors.statusInProgress : AppColors.divider,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        done ? Icons.check : Icons.flag_outlined,
                        size: 14,
                        color: done ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: done ? AppColors.statusInProgress : AppColors.divider,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                            color: done ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        if (step.$3 != null)
                          Text(
                            DateFormat('dd/MM · HH:mm').format(step.$3!.toLocal()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (!done)
                          const Text(
                            'Aguardando...',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
