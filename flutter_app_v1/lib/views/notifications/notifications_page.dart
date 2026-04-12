import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/animated_list_item.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton.icon(
            onPressed: () => _ctrl.markAllAsRead(),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Read all'),
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
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications',
              subtitle: 'You\'re all caught up!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _ctrl.notifications.length,
            itemBuilder: (_, i) {
              final n = _ctrl.notifications[i];
              final isUnread = n.isRead != true;
              return AnimatedListItem(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isUnread
                        ? colorScheme.primaryContainer.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        if (isUnread) _ctrl.markAsRead(n.id ?? '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isUnread
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.1)
                                    : colorScheme.outline
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIcon(n.type),
                                color: isUnread
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.content ?? '',
                                    style: TextStyle(
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Helpers.formatRelativeTime(
                                        n.createdAt ?? ''),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.outline,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
        return Icons.folder_rounded;
      case 'MESSAGE':
        return Icons.chat_rounded;
      case 'PAYMENT':
        return Icons.payment_rounded;
      case 'MEETING':
        return Icons.video_call_rounded;
      case 'REVIEW':
        return Icons.star_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
