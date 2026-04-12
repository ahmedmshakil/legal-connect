import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/chat_controller.dart';
import 'dashboard/user_dashboard_page.dart';
import 'dashboard/lawyer_dashboard_page.dart';
import 'cases/cases_list_page.dart';
import 'chat/chat_list_page.dart';
import 'ai_chat/ai_chat_page.dart';
import 'profile/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final bool _isLawyer;

  @override
  void initState() {
    super.initState();
    _isLawyer = Get.find<AuthController>().isLawyer;
    _pages = [
      _isLawyer ? const LawyerDashboardPage() : const UserDashboardPage(),
      const CasesListPage(),
      const ChatListPage(),
      const AiChatPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Ensure lazy controllers are instantiated
    final notifications = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    final chat = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder_rounded),
                label: 'Cases',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: chat.totalUnreadCount.value > 0,
                  label: Text('${chat.totalUnreadCount.value}'),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                selectedIcon: Badge(
                  isLabelVisible: chat.totalUnreadCount.value > 0,
                  label: Text('${chat.totalUnreadCount.value}'),
                  child: const Icon(Icons.chat_bubble_rounded),
                ),
                label: 'Chat',
              ),
              const NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy_rounded),
                label: 'AI',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: notifications.unreadCount.value > 0,
                  label: Text('${notifications.unreadCount.value}'),
                  child: const Icon(Icons.person_outline),
                ),
                selectedIcon: Badge(
                  isLabelVisible: notifications.unreadCount.value > 0,
                  label: Text('${notifications.unreadCount.value}'),
                  child: const Icon(Icons.person_rounded),
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      }),
    );
  }
}
