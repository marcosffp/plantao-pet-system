import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_request_provider.dart';
import 'caregiver_request_detail_screen.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final srProvider = context.watch<ServiceRequestProvider>();
    final openRequests = srProvider.openRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solicitações Abertas'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => srProvider.loadOpen(auth.user!.token),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => srProvider.loadOpen(auth.user!.token),
        child: srProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : openRequests.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🐾', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma solicitação aberta',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Puxe para atualizar',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: openRequests.length,
                    itemBuilder: (ctx, i) {
                      return _OpenRequestCard(
                        request: openRequests[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaregiverRequestDetailScreen(
                              request: openRequests[i],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _OpenRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onTap;

  const _OpenRequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final emoji = AppConstants.speciesEmoji[request.pet.species] ?? '🐾';
    final serviceLabel = AppConstants.serviceTypeLabels[request.serviceType] ?? request.serviceType;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(request.scheduledAt.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.pet.name} · ${request.pet.breed}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        serviceLabel,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusOpenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Aberta',
                    style: TextStyle(
                      color: AppColors.statusOpen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(dateStr, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.meetingAddress,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('Ver detalhes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
