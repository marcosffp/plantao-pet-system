import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/pet_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/service_request_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/pet_provider.dart';
import 'presentation/providers/service_request_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/caregiver/caregiver_main_screen.dart';
import 'presentation/screens/owner/owner_main_screen.dart';
import 'services/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const PlantaoPetApp());
}

class PlantaoPetApp extends StatelessWidget {
  const PlantaoPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final socket = SocketService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(), socket),
        ),
        ChangeNotifierProvider(
          create: (_) => PetProvider(PetRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceRequestProvider(ServiceRequestRepository(), socket),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(NotificationRepository(), socket),
        ),
      ],
      child: MaterialApp(
        title: 'PlantãoPet',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    await context.read<AuthProvider>().tryAutoLogin();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🐾', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        if (!auth.isAuthenticated) return const LoginScreen();
        if (auth.user!.isOwner) return const OwnerMainScreen();
        return const CaregiverMainScreen();
      },
    );
  }
}
