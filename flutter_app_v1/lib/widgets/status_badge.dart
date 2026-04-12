import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            _formatLabel(label),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  Color _getColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'PENDING':
      case 'DRAFT':
        return AppColors.warning;
      case 'IN_PROGRESS':
      case 'ACTIVE':
      case 'PAID':
        return AppColors.inProgress;
      case 'RESOLVED':
      case 'COMPLETED':
      case 'APPROVED':
      case 'PUBLISHED':
      case 'RELEASED':
        return AppColors.success;
      case 'CLOSED':
      case 'CANCELLED':
      case 'REJECTED':
        return AppColors.error;
      case 'VERIFIED':
        return AppColors.info;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}
