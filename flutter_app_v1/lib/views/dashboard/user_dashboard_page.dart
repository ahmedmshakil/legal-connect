import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/gradient_card.dart';
import '../../app/theme/app_colors.dart';
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
    // Stagger API calls to reduce main thread pressure
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.find<NotificationController>().fetchUnreadCount();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      Get.find<ChatController>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final notifications = Get.find<NotificationController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Obx(() {
                    final user = auth.userInfo.value;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colorScheme.outline),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.firstName ?? 'User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        // Notification bell
                        Obx(() => IconButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.notifications),
                              icon: Badge(
                                isLabelVisible:
                                    notifications.unreadCount.value > 0,
                                label:
                                    Text('${notifications.unreadCount.value}'),
                                child:
                                    const Icon(Icons.notifications_outlined, size: 26),
                              ),
                            )),
                        const SizedBox(width: 4),
                        ProfileAvatar(
                          name: user?.fullName ?? 'U',
                          imageUrl: user?.profilePictureUrl,
                          radius: 20,
                          onTap: () => Get.toNamed(AppRoutes.profile),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // Email verification banner
            SliverToBoxAdapter(
              child: Obx(() {
                if (auth.isEmailVerified) return const SizedBox.shrink();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warning, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Please verify your email address',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.verifyEmail),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                AppColors.warning.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.outline,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.search_rounded,
                            label: 'Find\nLawyers',
                            gradient: AppColors.primaryGradient,
                            onTap: () =>
                                Get.toNamed(AppRoutes.userFindLawyers),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.smart_toy_rounded,
                            label: 'AI\nAssistant',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                            ),
                            onTap: () => Get.toNamed(AppRoutes.aiChat),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.article_rounded,
                            label: 'Legal\nBlogs',
                            gradient: AppColors.accentGradient,
                            onTap: () => Get.toNamed(AppRoutes.blogs),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.payment_rounded,
                            label: 'My\nPayments',
                            gradient: AppColors.warmGradient,
                            onTap: () => Get.toNamed(AppRoutes.payments),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent cases header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Cases',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.userCases),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Cases list
            Obx(() {
              if (_caseCtrl.isLoading.value && _caseCtrl.cases.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              if (_caseCtrl.cases.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GradientCard(
                      color: Theme.of(context).cardColor,
                      onTap: () => Get.toNamed(AppRoutes.userCreateCase),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 44,
                              color: colorScheme.outline.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text('No cases yet'),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to create your first case',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final c = _caseCtrl.cases[i];
                      return AnimatedListItem(
                        index: i,
                        child: _CaseCard(
                          caseItem: c,
                          onTap: () =>
                              Get.toNamed('/user/cases/${c.id}'),
                        ),
                      );
                    },
                    childCount: _caseCtrl.cases.take(5).length,
                  ),
                ),
              );
            }),

            // FAB spacer
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.userCreateCase),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Case'),
      ),
    );
  }
}

// ─── Quick Action Card ───
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Case Card ───
class _CaseCard extends StatelessWidget {
  final dynamic caseItem;
  final VoidCallback onTap;

  const _CaseCard({required this.caseItem, required this.onTap});

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'IN_PROGRESS':
      case 'ACTIVE':
        return AppColors.inProgress;
      case 'RESOLVED':
      case 'COMPLETED':
        return AppColors.success;
      case 'CLOSED':
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(caseItem.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: statusColor, width: 3.5),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseItem.title ?? 'Untitled',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 13,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            Helpers.formatRelativeTime(
                                caseItem.createdAt ?? ''),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: caseItem.status ?? 'OPEN'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
