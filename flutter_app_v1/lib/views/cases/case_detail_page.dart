import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/schedule_controller.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';

class CaseDetailPage extends StatefulWidget {
  const CaseDetailPage({super.key});

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage>
    with SingleTickerProviderStateMixin {
  late CaseController _ctrl;
  late ScheduleController _schedCtrl;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(CaseController());
    _schedCtrl = Get.put(ScheduleController());
    _tabCtrl = TabController(length: 3, vsync: this);
    final id = Get.parameters['id'] ?? '';
    if (id.isNotEmpty) {
      _ctrl.getCaseById(id);
      _schedCtrl.loadSchedulesForCase(id);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Schedule'),
            Tab(text: 'Actions'),
          ],
        ),
      ),
      body: Obx(() {
        final c = _ctrl.currentCase.value;
        if (_ctrl.isLoading.value && c == null) {
          return const LoadingWidget();
        }
        if (c == null) {
          return const Center(child: Text('Case not found'));
        }

        return TabBarView(
          controller: _tabCtrl,
          children: [
            // Details tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.title ?? '',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      StatusBadge(label: c.status ?? 'OPEN'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    context,
                    'Created',
                    Helpers.formatDate(c.createdAt ?? ''),
                  ),
                  if (c.updatedAt != null)
                    _infoRow(
                      context,
                      'Updated',
                      Helpers.formatDate(c.updatedAt!),
                    ),
                  _infoRow(context, 'Client', c.clientFullName),
                  if (c.lawyerFirstName != null)
                    _infoRow(context, 'Lawyer', c.lawyerFullName),
                  const Divider(height: 32),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.description ?? 'No description provided',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Schedule tab
            Obx(() {
              final schedules = _schedCtrl.caseSchedules;
              if (schedules.isEmpty) {
                return const Center(child: Text('No schedules'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                itemBuilder: (_, i) {
                  final s = schedules[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(s.type ?? 'Schedule'),
                      subtitle: Text(
                        '${Helpers.formatDate(s.date ?? '')} ${s.startTime ?? ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _schedCtrl.deleteSchedule(s.id ?? ''),
                      ),
                    ),
                  );
                },
              );
            }),
            // Actions tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.isLawyer) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showStatusDialog(c.id ?? ''),
                      icon: const Icon(Icons.update),
                      label: const Text('Update Status'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed(
                      '${AppRoutes.chat}?to=${auth.isLawyer ? c.clientId : c.lawyerId}',
                    ),
                    icon: const Icon(Icons.chat),
                    label: Text(
                      'Message ${auth.isLawyer ? 'Client' : 'Lawyer'}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showScheduleDialog(c.id ?? ''),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add Schedule'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.meetings),
                    icon: const Icon(Icons.video_call),
                    label: const Text('Schedule Meeting'),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(String caseId) {
    final statuses = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Update Status'),
        children: statuses
            .map(
              (s) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _ctrl.updateCaseStatus(caseId, {'status': s});
                },
                child: Text(s.replaceAll('_', ' ')),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showScheduleDialog(String caseId) {
    final typeCtrl = TextEditingController();
    DateTime? date;
    TimeOfDay? time;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Select Date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                date = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
              },
            ),
            ListTile(
              title: const Text('Select Time'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                time = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.now(),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _schedCtrl
                  .createSchedule({
                    'caseId': caseId,
                    'type': typeCtrl.text,
                    'date': date?.toIso8601String().split('T').first ?? '',
                    'startTime': time != null
                        ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                        : '',
                  })
                  .then((_) => _schedCtrl.loadSchedulesForCase(caseId));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
