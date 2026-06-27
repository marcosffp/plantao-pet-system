import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/service_request_provider.dart';
import 'caregiver_home_screen.dart';
import 'caregiver_my_requests_screen.dart';
import 'caregiver_notifications_screen.dart';
import 'caregiver_profile_screen.dart';

class CaregiverMainScreen extends StatefulWidget {
  const CaregiverMainScreen({super.key});

  @override
  State<CaregiverMainScreen> createState() => _CaregiverMainScreenState();
}

class _CaregiverMainScreenState extends State<CaregiverMainScreen> {
  int _currentIndex = 0;

  late final _screens = [
    CaregiverHomeScreen(onAccepted: () => setState(() => _currentIndex = 1)),
    const CaregiverMyRequestsScreen(),
    CaregiverNotificationsScreen(
      onNavigate: (i) {
        setState(() => _currentIndex = i);
        if (i == 3) context.read<AuthProvider>().refreshProfile();
      },
    ),
    const CaregiverProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final auth = context.read<AuthProvider>();
    final token = auth.user!.token;
    final srProvider = context.read<ServiceRequestProvider>();
    final notifProvider = context.read<NotificationProvider>();

    srProvider.loadOpen(token);
    srProvider.loadMine(token);
    srProvider.listenToSocket(token);
    notifProvider.load(token);
    notifProvider.listenToSocket(token);
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 3) context.read<AuthProvider>().refreshProfile();
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Meus',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications),
            ),
            label: 'Alertas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
