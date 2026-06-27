import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class CaregiverNotificationsScreen extends StatelessWidget {
  final void Function(int index)? onNavigate;

  const CaregiverNotificationsScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifProvider.load(auth.user!.token),
        child: notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma notificação',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (ctx, i) {
                  final n = notifications[i];
                  return GestureDetector(
                    onTap: () {
                      if (!n.isRead) notifProvider.markRead(n.id, auth.user!.token);
                      if (n.eventType == 'service_request.created') {
                        onNavigate?.call(0);
                      } else if (n.eventType == 'review.created') {
                        onNavigate?.call(3);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead ? AppColors.surface : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: n.isRead ? AppColors.divider : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: n.isRead ? AppColors.divider : AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _iconForEvent(n.eventType),
                              color: n.isRead ? AppColors.textSecondary : Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM HH:mm').format(n.createdAt.toLocal()),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _iconForEvent(String eventType) {
    switch (eventType) {
      case 'new_request':
        return Icons.pets;
      case 'review.created':
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
