import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/pet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/service_request_provider.dart';

class CreateServiceRequestScreen extends StatefulWidget {
  const CreateServiceRequestScreen({super.key});

  @override
  State<CreateServiceRequestScreen> createState() => _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState extends State<CreateServiceRequestScreen> {
  Pet? _selectedPet;
  String _serviceType = 'WALK_30MIN';
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  final _addressCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static final _services = [
    ('WALK_30MIN', 'Passeio', '30 min', Icons.directions_walk),
    ('WALK_1H', 'Passeio', '1 hora', Icons.directions_walk),
    ('HOME_VISIT', 'Visita', 'Domiciliar', Icons.home_outlined),
    ('HOSTING', 'Hospedagem', 'Temporária', Icons.bed_outlined),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPets());
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _loadPets() {
    final auth = context.read<AuthProvider>();
    context.read<PetProvider>().load(auth.user!.id, auth.user!.token);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final minDate = now.add(const Duration(hours: 2));
    final d = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (d != null) setState(() => _scheduledDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _scheduledTime = t);
  }

  Future<void> _submit() async {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um pet')),
      );
      return;
    }
    if (_scheduledDate == null || _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data e horário')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final scheduledAt = DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );

    final minScheduled = DateTime.now().add(const Duration(hours: 2));
    if (scheduledAt.isBefore(minScheduled)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O agendamento deve ser feito com pelo menos 2 horas de antecedência'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await context.read<ServiceRequestProvider>().create(
          token: auth.user!.token,
          petId: _selectedPet!.id,
          serviceType: _serviceType,
          scheduledAt: scheduledAt,
          meetingAddress: _addressCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      final err = context.read<ServiceRequestProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Erro ao criar solicitação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetProvider>().pets;
    final srProvider = context.watch<ServiceRequestProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nova solicitação'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                icon: Icons.pets,
                title: 'SELECIONAR PET',
                child: pets.isEmpty
                    ? const Text(
                        'Cadastre um pet antes de criar uma solicitação',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: pets.map((pet) {
                            final selected = _selectedPet?.id == pet.id;
                            final emoji = AppConstants.speciesEmoji[pet.species] ?? '🐾';
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPet = pet),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                width: 90,
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primaryLight : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? AppColors.primary : AppColors.divider,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(emoji, style: const TextStyle(fontSize: 32)),
                                    const SizedBox(height: 4),
                                    Text(
                                      pet.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                        color: selected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.calendar_month,
                title: 'TIPO DE SERVIÇO',
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: _services.map((svc) {
                    final selected = _serviceType == svc.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _serviceType = svc.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.divider,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              svc.$4,
                              size: 20,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  svc.$2,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  svc.$3,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.calendar_today,
                title: 'DATA E HORÁRIO',
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                _scheduledDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_scheduledDate!)
                                    : 'Data',
                                style: TextStyle(
                                  color: _scheduledDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                _scheduledTime != null
                                    ? _scheduledTime!.format(context)
                                    : 'Horário',
                                style: TextStyle(
                                  color: _scheduledTime != null
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.location_on,
                title: 'ENDEREÇO DE ATENDIMENTO',
                child: TextFormField(
                  controller: _addressCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Rua, número, bairro',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                  validator: (v) => v == null || v.length < 5 ? 'Endereço obrigatório' : null,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          children: [
                            TextSpan(text: 'O agendamento deve ser feito com pelo menos '),
                            TextSpan(
                              text: '2 horas de antecedência',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            TextSpan(
                              text:
                                  '. A solicitação expira automaticamente em 24h se não aceita.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: srProvider.loading ? null : _submit,
                  child: srProvider.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Criar Solicitação'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
