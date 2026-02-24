import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/meeting_controller.dart';
import '../../widgets/empty_state_widget.dart';
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
              icon: Icons.video_call_outlined,
              title: 'No Meetings',
              subtitle: 'Schedule meetings from case details',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _ctrl.meetings.length,
            itemBuilder: (_, i) {
              final m = _ctrl.meetings[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.video_call)),
                  title: Text(m.roomName ?? 'Meeting'),
                  subtitle: Text(
                    Helpers.formatDate(m.startTimestamp ?? m.createdAt ?? ''),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _ctrl.joinMeeting(m.id ?? ''),
                    child: const Text('Join'),
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
