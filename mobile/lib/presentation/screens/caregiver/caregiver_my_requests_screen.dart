import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_request_provider.dart';
import '../../widgets/service_request_card.dart';
import 'caregiver_request_detail_screen.dart';

class CaregiverMyRequestsScreen extends StatelessWidget {
  const CaregiverMyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final srProvider = context.watch<ServiceRequestProvider>();
    final requests = srProvider.requests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Atendimentos'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => srProvider.loadMine(auth.user!.token),
        child: srProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : requests.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum atendimento ainda',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (ctx, i) {
                      final req = requests[i];
                      return ServiceRequestCard(
                        request: req,
                        highlighted: req.status == 'IN_PROGRESS',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaregiverRequestDetailScreen(request: req),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
