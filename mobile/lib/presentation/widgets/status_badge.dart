import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'OPEN':
        return AppColors.statusOpen;
      case 'ACCEPTED':
        return AppColors.statusAccepted;
      case 'IN_PROGRESS':
        return AppColors.statusInProgress;
      case 'COMPLETED':
        return AppColors.statusCompleted;
      case 'CANCELLED':
        return AppColors.statusCancelled;
      case 'REFUSED':
        return AppColors.statusRefused;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _bgColor {
    switch (status) {
      case 'OPEN':
        return AppColors.statusOpenBg;
      case 'ACCEPTED':
        return AppColors.statusAcceptedBg;
      case 'IN_PROGRESS':
        return AppColors.statusInProgressBg;
      case 'COMPLETED':
        return AppColors.statusCompletedBg;
      case 'CANCELLED':
        return AppColors.statusCancelledBg;
      case 'REFUSED':
        return AppColors.statusRefusedBg;
      default:
        return AppColors.statusCompletedBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == 'IN_PROGRESS') ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            AppConstants.statusLabels[status] ?? status,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
