import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/confirm_dialog.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/helpers.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  late ScheduleController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ScheduleController());
    _ctrl.loadAllSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedules')),
      body: RefreshIndicator(
        onRefresh: () async => _ctrl.loadAllSchedules(),
        child: Obx(() {
          if (_ctrl.isLoading.value && _ctrl.schedules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_ctrl.schedules.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.calendar_today_rounded,
              title: 'No Schedules',
              subtitle: 'Schedules will appear here when created from cases',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: _ctrl.schedules.length,
            itemBuilder: (_, i) {
              final s = _ctrl.schedules[i];
              return AnimatedListItem(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date badge
                          Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.event_rounded,
                                    size: 20, color: colorScheme.primary),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDay(s.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.type ?? 'Schedule',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Helpers.formatDate(s.date ?? ''),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: colorScheme.outline),
                                ),
                                if (s.startTime != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 13,
                                          color: colorScheme.outline),
                                      const SizedBox(width: 4),
                                      Text(
                                        s.startTime!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: colorScheme.outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: AppColors.error, size: 20),
                            onPressed: () async {
                              final ok = await ConfirmDialog.show(
                                context,
                                title: 'Delete Schedule',
                                message:
                                    'Are you sure you want to delete this schedule?',
                                confirmLabel: 'Delete',
                                isDestructive: true,
                              );
                              if (ok == true) _ctrl.deleteSchedule(s.id ?? '');
                            },
                          ),
                        ],
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

  String _formatDay(String? date) {
    if (date == null || date.isEmpty) return '--';
    try {
      final d = DateTime.parse(date);
      return '${d.day}';
    } catch (_) {
      return '--';
    }
  }
}
