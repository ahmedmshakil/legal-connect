import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/theme_controller.dart';
import '../routes/app_routes.dart';
import 'profile_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Get.find<ThemeController>();
    final notifications = Get.find<NotificationController>();
    final chat = Get.find<ChatController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Obx(() {
              final user = auth.userInfo.value;
              return UserAccountsDrawerHeader(
                accountName: Text(user?.fullName ?? 'User'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: ProfileAvatar(
                  name: user?.fullName ?? 'U',
                  imageUrl: user?.profilePictureUrl,
                  radius: 30,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }),
            // Menu items
            Expanded(
              child: Obx(() {
                final isLawyer = auth.isLawyer;
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildTile(
                      context,
                      Icons.dashboard,
                      'Dashboard',
                      isLawyer
                          ? AppRoutes.lawyerDashboard
                          : AppRoutes.userDashboard,
                    ),
                    _buildTile(
                      context,
                      Icons.folder,
                      'Cases',
                      isLawyer ? AppRoutes.lawyerCases : AppRoutes.userCases,
                    ),
                    if (!isLawyer)
                      _buildTile(
                        context,
                        Icons.search,
                        'Find Lawyers',
                        AppRoutes.userFindLawyers,
                      ),
                    _buildTile(
                      context,
                      Icons.chat,
                      'Messages',
                      AppRoutes.chat,
                      badge: chat.totalUnreadCount.value,
                    ),
                    _buildTile(
                      context,
                      Icons.smart_toy,
                      'AI Assistant',
                      AppRoutes.aiChat,
                    ),
                    _buildTile(
                      context,
                      Icons.article,
                      'Blogs',
                      AppRoutes.blogs,
                    ),
                    _buildTile(
                      context,
                      Icons.video_call,
                      'Meetings',
                      AppRoutes.meetings,
                    ),
                    _buildTile(
                      context,
                      Icons.calendar_today,
                      'Schedules',
                      AppRoutes.schedules,
                    ),
                    _buildTile(
                      context,
                      Icons.payment,
                      'Payments',
                      AppRoutes.payments,
                    ),
                    _buildTile(
                      context,
                      Icons.notifications,
                      'Notifications',
                      AppRoutes.notifications,
                      badge: notifications.unreadCount.value,
                    ),
                    const Divider(),
                    _buildTile(
                      context,
                      Icons.person,
                      'Profile',
                      AppRoutes.profile,
                    ),
                    ListTile(
                      leading: Icon(
                        theme.isDark.value ? Icons.light_mode : Icons.dark_mode,
                      ),
                      title: Text(
                        theme.isDark.value ? 'Light Mode' : 'Dark Mode',
                      ),
                      onTap: () => theme.toggleTheme(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => auth.logout(),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    int badge = 0,
  }) {
    final isActive = Get.currentRoute == route;
    return ListTile(
      leading: Badge(
        isLabelVisible: badge > 0,
        label: Text('$badge'),
        child: Icon(
          icon,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isActive,
      onTap: () {
        Get.back(); // close drawer
        if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }
}
