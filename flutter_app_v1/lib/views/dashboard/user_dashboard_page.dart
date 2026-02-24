import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/status_badge.dart';
import '../../utils/helpers.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  late CaseController _caseCtrl;

  @override
  void initState() {
    super.initState();
    _caseCtrl = Get.put(CaseController());
    _loadData();
  }

  void _loadData() {
    _caseCtrl.getAllUserCases(reset: true);
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
          () => Text('Hi, ${auth.userInfo.value?.firstName ?? 'User'}'),
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
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ProfileAvatar(
                name: auth.userInfo.value?.fullName ?? 'U',
                imageUrl: auth.userInfo.value?.profilePictureUrl,
                radius: 16,
                onTap: () => Get.toNamed(AppRoutes.profile),
              ),
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
              // Email verification banner
              Obx(() {
                if (auth.isEmailVerified) return const SizedBox.shrink();
                return Card(
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text('Verify your email'),
                    trailing: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.verifyEmail),
                      child: const Text('Verify'),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Quick actions
              _buildQuickActions(context),
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
                    onPressed: () => Get.toNamed(AppRoutes.userCases),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (_caseCtrl.isLoading.value && _caseCtrl.cases.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_caseCtrl.cases.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          const Text('No cases yet'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.userCreateCase),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Case'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _caseCtrl.cases.take(5).length,
                  itemBuilder: (_, i) => _buildCaseCard(_caseCtrl.cases[i]),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.userCreateCase),
        icon: const Icon(Icons.add),
        label: const Text('New Case'),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _actionCard(
          context,
          Icons.search,
          'Find Lawyers',
          AppRoutes.userFindLawyers,
          Colors.blue,
        ),
        _actionCard(
          context,
          Icons.smart_toy,
          'AI Assistant',
          AppRoutes.aiChat,
          Colors.purple,
        ),
        _actionCard(
          context,
          Icons.article,
          'Blogs',
          AppRoutes.blogs,
          Colors.teal,
        ),
        _actionCard(
          context,
          Icons.payment,
          'Payments',
          AppRoutes.payments,
          Colors.green,
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    Color color,
  ) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(dynamic caseItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          caseItem.title ?? 'Untitled',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(Helpers.formatRelativeTime(caseItem.createdAt ?? '')),
        trailing: StatusBadge(label: caseItem.status ?? 'OPEN'),
        onTap: () => Get.toNamed('/user/cases/${caseItem.id}'),
      ),
    );
  }
}
