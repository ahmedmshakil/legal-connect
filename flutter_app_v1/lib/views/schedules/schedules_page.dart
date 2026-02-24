import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../widgets/empty_state_widget.dart';
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
              icon: Icons.calendar_today_outlined,
              title: 'No Schedules',
              subtitle: 'Schedules will appear here when created from cases',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _ctrl.schedules.length,
            itemBuilder: (_, i) {
              final s = _ctrl.schedules[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.event)),
                  title: Text(s.type ?? 'Schedule'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Helpers.formatDate(s.date ?? '')),
                      if (s.startTime != null) Text('Time: ${s.startTime}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _ctrl.deleteSchedule(s.id ?? ''),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
