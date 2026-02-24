import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/lawyer_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/status_badge.dart';

class LawyerDashboardPage extends StatefulWidget {
  const LawyerDashboardPage({super.key});

  @override
  State<LawyerDashboardPage> createState() => _LawyerDashboardPageState();
}

class _LawyerDashboardPageState extends State<LawyerDashboardPage> {
  late CaseController _caseCtrl;
  late LawyerController _lawyerCtrl;

  @override
  void initState() {
    super.initState();
    _caseCtrl = Get.put(CaseController());
    _lawyerCtrl = Get.put(LawyerController());
    _loadData();
  }

  void _loadData() {
    _caseCtrl.getAllUserCases(reset: true);
    _lawyerCtrl.fetchLawyerInfo();
    Get.find<NotificationController>().fetchUnreadCount();
    Get.find<ChatController>().fetchUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final notifications = Get.find<NotificationController>();
    final chat = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text('Hi, ${auth.userInfo.value?.firstName ?? 'Lawyer'}'),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Badge(
                isLabelVisible: chat.totalUnreadCount.value > 0,
                label: Text('${chat.totalUnreadCount.value}'),
                child: const Icon(Icons.chat_outlined),
              ),
              onPressed: () => Get.toNamed(AppRoutes.chat),
            ),
          ),
          Obx(
            () => IconButton(
              icon: Badge(
                isLabelVisible: notifications.unreadCount.value > 0,
                label: Text('${notifications.unreadCount.value}'),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Get.toNamed(AppRoutes.notifications),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile status
              Obx(() {
                if (_lawyerCtrl.lawyerInfo.value == null) {
                  return Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.info, color: Colors.blue),
                      title: const Text('Complete your profile'),
                      subtitle: const Text(
                        'Set up your lawyer profile to start accepting cases',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.lawyerOnboarding),
                        child: const Text('Setup'),
                      ),
                    ),
                  );
                }
                if (_lawyerCtrl.isPending) {
                  return Card(
                    color: Colors.orange.shade50,
                    child: const ListTile(
                      leading: Icon(
                        Icons.hourglass_bottom,
                        color: Colors.orange,
                      ),
                      title: Text('Profile Under Review'),
                      subtitle: Text(
                        'Your profile is being reviewed by the admin.',
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              // Stats
              Obx(
                () => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2,
                  children: [
                    _statCard(
                      context,
                      'Total Cases',
                      '${_caseCtrl.cases.length}',
                      Icons.folder,
                      Colors.blue,
                    ),
                    _statCard(
                      context,
                      'Active',
                      '${_caseCtrl.inProgressCases.length}',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _statCard(
                      context,
                      'Resolved',
                      '${_caseCtrl.resolvedCases.length}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _statCard(
                      context,
                      'Rating',
                      _lawyerCtrl.lawyerInfo.value?.averageRating
                              ?.toStringAsFixed(1) ??
                          '-',
                      Icons.star,
                      Colors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Quick actions
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _quickAction(
                    context,
                    Icons.smart_toy,
                    'AI Chat',
                    AppRoutes.aiChat,
                  ),
                  _quickAction(
                    context,
                    Icons.video_call,
                    'Meetings',
                    AppRoutes.meetings,
                  ),
                  _quickAction(
                    context,
                    Icons.article,
                    'Blogs',
                    AppRoutes.blogs,
                  ),
                  _quickAction(
                    context,
                    Icons.calendar_today,
                    'Schedule',
                    AppRoutes.schedules,
                  ),
                  _quickAction(
                    context,
                    Icons.payment,
                    'Payments',
                    AppRoutes.payments,
                  ),
                  _quickAction(
                    context,
                    Icons.person,
                    'Profile',
                    AppRoutes.lawyerProfile,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent cases
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Cases',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.lawyerCases),
                    child: const Text('View All'),
                  ),
                ],
              ),
              Obx(() {
                if (_caseCtrl.cases.isEmpty && !_caseCtrl.isLoading.value) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No cases assigned yet')),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _caseCtrl.cases.take(5).length,
                  itemBuilder: (_, i) {
                    final c = _caseCtrl.cases[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: ProfileAvatar(
                          name: c.clientFullName,
                          radius: 20,
                        ),
                        title: Text(
                          c.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(c.clientFullName),
                        trailing: StatusBadge(label: c.status ?? 'OPEN'),
                        onTap: () => Get.toNamed('/lawyer/cases/${c.id}'),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
