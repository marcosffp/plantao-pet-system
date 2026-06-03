import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final bool initialIsOwner;

  const RegisterScreen({super.key, this.initialIsOwner = true});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late bool _isOwner;
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _neighborhoodsCtrl = TextEditingController();

  final List<String> _selectedServices = [];
  bool _obscure = true;

  static final _serviceOptions = [
    ('WALK_30MIN', 'Passeio 30min'),
    ('WALK_1H', 'Passeio 1h'),
    ('HOME_VISIT', 'Visita Domiciliar'),
    ('HOSTING', 'Hospedagem'),
  ];

  @override
  void initState() {
    super.initState();
    _isOwner = widget.initialIsOwner;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    _neighborhoodsCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    bool ok;

    if (_isOwner) {
      ok = await auth.registerOwner(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
        address: _addressCtrl.text.trim(),
        password: _passCtrl.text,
      );
    } else {
      if (_selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos um serviço')),
        );
        return;
      }
      final neighborhoods = _neighborhoodsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (neighborhoods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe pelo menos um bairro')),
        );
        return;
      }
      ok = await auth.registerCaregiver(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
        neighborhoods: neighborhoods,
        services: _selectedServices,
        password: _passCtrl.text,
      );
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erro ao criar conta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Criar conta'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TIPO DE PERFIL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              _RoleToggle(
                isOwner: _isOwner,
                onChanged: (v) => setState(() {
                  _isOwner = v;
                  _selectedServices.clear();
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                'DADOS PESSOAIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const Divider(height: 16),
              const SizedBox(height: 8),
              _label('NOME COMPLETO'),
              const SizedBox(height: 8),
              _field(
                controller: _nameCtrl,
                hint: 'Seu nome completo',
                validator: (v) => v == null || v.length < 2 ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('EMAIL'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _emailCtrl,
                          hint: 'seu@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v == null || !v.contains('@') ? 'Email inválido' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('TELEFONE'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _phoneCtrl,
                          hint: '(11) 99999-0000',
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.replaceAll(RegExp(r'\D'), '').length < 10
                                  ? 'Telefone inválido'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isOwner) ...[
                _label('ENDEREÇO'),
                const SizedBox(height: 8),
                _field(
                  controller: _addressCtrl,
                  hint: 'Rua, número, bairro, cidade',
                  validator: (v) =>
                      v == null || v.length < 5 ? 'Endereço obrigatório' : null,
                ),
                const SizedBox(height: 16),
              ] else ...[
                _label('BAIRROS ATENDIDOS'),
                const SizedBox(height: 4),
                const Text(
                  'Separe por vírgula: Centro, Vila Madalena',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                _field(
                  controller: _neighborhoodsCtrl,
                  hint: 'Centro, Vila Madalena',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe os bairros' : null,
                ),
                const SizedBox(height: 16),
                _label('SERVIÇOS OFERECIDOS'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _serviceOptions.map((opt) {
                    final selected = _selectedServices.contains(opt.$1);
                    return FilterChip(
                      label: Text(opt.$2),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedServices.add(opt.$1);
                          } else {
                            _selectedServices.remove(opt.$1);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              _label('SENHA'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.statusInProgress, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seus dados são protegidos e não serão compartilhados sem consentimento.',
                        style: TextStyle(fontSize: 13, color: AppColors.statusInProgress),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : _register,
                  child: auth.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Criar conta'),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  children: [
                    TextSpan(text: 'Ao criar sua conta, você concorda com os '),
                    TextSpan(
                      text: 'Termos de Uso',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(text: ' e a '),
                    TextSpan(
                      text: 'Política de Privacidade',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: hint),
        validator: validator,
      );
}

class _RoleToggle extends StatelessWidget {
  final bool isOwner;
  final ValueChanged<bool> onChanged;

  const _RoleToggle({required this.isOwner, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ToggleButton(
          label: 'Dono do Pet',
          icon: Icons.favorite_border,
          selected: isOwner,
          onTap: () => onChanged(true),
        )),
        const SizedBox(width: 12),
        Expanded(child: _ToggleButton(
          label: 'Cuidador',
          icon: Icons.star_border,
          selected: !isOwner,
          onTap: () => onChanged(false),
        )),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
