import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'PENDING':
      case 'DRAFT':
        return Colors.orange;
      case 'IN_PROGRESS':
      case 'ACTIVE':
      case 'PAID':
        return Colors.blue;
      case 'RESOLVED':
      case 'COMPLETED':
      case 'APPROVED':
      case 'PUBLISHED':
      case 'RELEASED':
        return Colors.green;
      case 'CLOSED':
      case 'CANCELLED':
      case 'REJECTED':
        return Colors.red;
      case 'VERIFIED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
