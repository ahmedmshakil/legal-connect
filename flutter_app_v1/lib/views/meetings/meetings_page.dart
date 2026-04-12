import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/meeting_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/animated_list_item.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/helpers.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  late MeetingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(MeetingController());
    _ctrl.loadMeetings();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Meetings')),
      body: RefreshIndicator(
        onRefresh: () async => _ctrl.loadMeetings(),
        child: Obx(() {
          if (_ctrl.isLoading.value && _ctrl.meetings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_ctrl.meetings.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.video_call_rounded,
              title: 'No Meetings',
              subtitle: 'Schedule meetings from case details',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: _ctrl.meetings.length,
            itemBuilder: (_, i) {
              final m = _ctrl.meetings[i];
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.video_call_rounded,
                                color: Color(0xFF7C3AED), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.roomName ?? 'Meeting',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 13,
                                        color: colorScheme.outline),
                                    const SizedBox(width: 4),
                                    Text(
                                      Helpers.formatDate(m.startTimestamp ??
                                          m.createdAt ??
                                          ''),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: colorScheme.outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _ctrl.joinMeeting(m.id ?? ''),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text('Join',
                                style: TextStyle(fontSize: 13)),
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
}
