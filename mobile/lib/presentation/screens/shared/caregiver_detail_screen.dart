import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/caregiver_repository.dart';
import '../../providers/auth_provider.dart';

class CaregiverDetailScreen extends StatefulWidget {
  final String caregiverId;
  final String? caregiverName;

  const CaregiverDetailScreen({
    super.key,
    required this.caregiverId,
    this.caregiverName,
  });

  @override
  State<CaregiverDetailScreen> createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen> {
  final _repo = CaregiverRepository();
  CaregiverSummary? _caregiver;
  List<Review> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().user!.token;
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _repo.getById(widget.caregiverId, token),
        _repo.getReviews(widget.caregiverId, token),
      ]);
      setState(() {
        _caregiver = results[0] as CaregiverSummary;
        _reviews = results[1] as List<Review>;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.caregiverName ?? 'Cuidador'),
        backgroundColor: AppColors.surface,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final c = _caregiver!;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    c.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                c.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.ratingColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    c.averageRating?.toStringAsFixed(1) ?? '–',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${_reviews.length} ${_reviews.length == 1 ? 'avaliação' : 'avaliações'})',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: c.status == 'ACTIVE' ? AppColors.successLight : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: c.status == 'ACTIVE' ? AppColors.successBorder : AppColors.divider,
                  ),
                ),
                child: Text(
                  c.status == 'ACTIVE' ? 'Disponível' : 'Indisponível',
                  style: TextStyle(
                    color: c.status == 'ACTIVE' ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: 'INFORMAÇÕES',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(icon: Icons.phone_outlined, label: 'Telefone', value: c.phone),
              if (c.neighborhoods.isNotEmpty) ...[
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.map_outlined,
                  label: 'Bairros atendidos',
                  value: c.neighborhoods.join(', '),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (c.services.isNotEmpty)
          _Card(
            title: 'SERVIÇOS OFERECIDOS',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: c.services.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppConstants.serviceTypeLabels[s] ?? s,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 12),
        _Card(
          title: 'AVALIAÇÕES',
          child: _reviews.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nenhuma avaliação ainda.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                )
              : Column(
                  children: _reviews.map((r) => _ReviewTile(review: r)).toList(),
                ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(review.createdAt.toLocal());
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.ratingColor,
                  );
                }),
              ),
              const Spacer(),
              Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(review.comment, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
