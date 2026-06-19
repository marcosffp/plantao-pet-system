import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_request_provider.dart';
import '../../widgets/service_request_card.dart';
import 'caregiver_request_detail_screen.dart';

class CaregiverMyRequestsScreen extends StatefulWidget {
  const CaregiverMyRequestsScreen({super.key});

  @override
  State<CaregiverMyRequestsScreen> createState() => _CaregiverMyRequestsScreenState();
}

class _CaregiverMyRequestsScreenState extends State<CaregiverMyRequestsScreen> {
  int _filterIndex = 0;

  static const _filters = ['Todos', 'Aceitos', 'Em andamento', 'Concluídos', 'Cancelados'];
  static const _filterStatuses = [null, 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];

  List<ServiceRequest> _filtered(List<ServiceRequest> all) {
    final status = _filterStatuses[_filterIndex];
    if (status == null) return all;
    return all.where((r) => r.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final srProvider = context.watch<ServiceRequestProvider>();
    final filtered = _filtered(srProvider.requests);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Atendimentos'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => srProvider.loadMine(auth.user!.token),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${srProvider.requests.length} atendimento${srProvider.requests.length == 1 ? '' : 's'} no total',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FilterRow(
                    selected: _filterIndex,
                    filters: _filters,
                    onSelected: (i) => setState(() => _filterIndex = i),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: srProvider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.work_outline, size: 56, color: AppColors.divider),
                              const SizedBox(height: 12),
                              Text(
                                _filterIndex == 0
                                    ? 'Nenhum atendimento ainda'
                                    : 'Nenhum atendimento neste filtro',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final req = filtered[i];
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
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final int selected;
  final List<String> filters;
  final ValueChanged<int> onSelected;

  const _FilterRow({
    required this.selected,
    required this.filters,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
