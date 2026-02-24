import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../utils/helpers.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<NotificationController>();
    _ctrl.loadNotifications(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => _ctrl.markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _ctrl.loadNotifications(reset: true),
        child: Obx(() {
          if (_ctrl.isLoading.value && _ctrl.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_ctrl.notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              subtitle: 'You\'re all caught up!',
            );
          }
          return ListView.builder(
            itemCount: _ctrl.notifications.length,
            itemBuilder: (_, i) {
              final n = _ctrl.notifications[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead == true
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    _getIcon(n.type),
                    color: n.isRead == true
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  n.content ?? '',
                  style: TextStyle(
                    fontWeight: n.isRead == true
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  Helpers.formatRelativeTime(n.createdAt ?? ''),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                tileColor: n.isRead == true
                    ? null
                    : Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                onTap: () {
                  if (n.isRead != true) {
                    _ctrl.markAsRead(n.id ?? '');
                  }
                },
              );
            },
          );
        }),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'CASE':
        return Icons.folder;
      case 'MESSAGE':
        return Icons.chat;
      case 'PAYMENT':
        return Icons.payment;
      case 'MEETING':
        return Icons.video_call;
      case 'REVIEW':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
