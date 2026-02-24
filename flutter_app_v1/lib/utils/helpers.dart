import 'package:intl/intl.dart';

class Helpers {
  // Date formatting
  static String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return timeStr;
    }
  }

  static String formatRelativeTime(String? dateStr) => relativeTime(dateStr);

  static String truncateText(String text, int maxLength) =>
      truncate(text, maxLength);

  static String relativeTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (_) {
      return dateStr;
    }
  }

  // Currency formatting (BDT)
  static String formatCurrency(dynamic amount) {
    if (amount == null) return '৳0.00';
    final num value = amount is String ? double.tryParse(amount) ?? 0 : amount;
    return '৳${NumberFormat('#,##0.00').format(value)}';
  }

  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  // Name initials for avatar
  static String getInitials(String? firstName, [String? lastName]) {
    if (lastName != null) {
      final f = firstName != null && firstName.isNotEmpty
          ? firstName[0].toUpperCase()
          : '';
      final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
      return '$f$l'.isNotEmpty ? '$f$l' : '?';
    }
    // Single name: extract first letter(s) from words
    final name = firstName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Case status display
  static String formatCaseStatus(String? status) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return status ?? 'Unknown';
    }
  }

  // Verification status display
  static String formatVerificationStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }
}
