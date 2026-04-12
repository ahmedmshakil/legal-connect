import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/lawyer_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/animated_list_item.dart';
import '../../app/theme/app_colors.dart';

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
                        ProfileAvatar(
                          name: user?.fullName ?? 'L',
                          imageUrl: user?.profilePictureUrl,
                          radius: 24,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: colorScheme.outline),
                              ),
                              Text(
                                user?.firstName ?? 'Lawyer',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Obx(() => IconButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.notifications),
                              icon: Badge(
                                isLabelVisible:
                                    notifications.unreadCount.value > 0,
                                label:
                                    Text('${notifications.unreadCount.value}'),
                                child: const Icon(
                                    Icons.notifications_outlined, size: 26),
                              ),
                            )),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // Profile status banner
            SliverToBoxAdapter(
              child: Obx(() {
                if (_lawyerCtrl.lawyerInfo.value == null) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Complete your profile',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                SizedBox(height: 2),
                                Text(
                                    'Set up your profile to start accepting cases',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  );
                }
                if (_lawyerCtrl.isPending) {
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
                          const Icon(Icons.hourglass_bottom_rounded,
                              color: AppColors.warning, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Profile Under Review',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text(
                                  'Your profile is being reviewed by the admin.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.outline),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),

            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total',
                          value: '${_caseCtrl.cases.length}',
                          icon: Icons.folder_rounded,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Active',
                          value: '${_caseCtrl.inProgressCases.length}',
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Done',
                          value: '${_caseCtrl.resolvedCases.length}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Rating',
                          value: _lawyerCtrl.lawyerInfo.value?.averageRating
                                  ?.toStringAsFixed(1) ??
                              '-',
                          icon: Icons.star_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.outline,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 82,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _QuickActionChip(
                      icon: Icons.smart_toy_rounded,
                      label: 'AI Chat',
                      onTap: () => Get.toNamed(AppRoutes.aiChat),
                    ),
                    _QuickActionChip(
                      icon: Icons.video_call_rounded,
                      label: 'Meetings',
                      onTap: () => Get.toNamed(AppRoutes.meetings),
                    ),
                    _QuickActionChip(
                      icon: Icons.article_rounded,
                      label: 'Blogs',
                      onTap: () => Get.toNamed(AppRoutes.blogs),
                    ),
                    _QuickActionChip(
                      icon: Icons.calendar_today_rounded,
                      label: 'Schedule',
                      onTap: () => Get.toNamed(AppRoutes.schedules),
                    ),
                    _QuickActionChip(
                      icon: Icons.payment_rounded,
                      label: 'Payments',
                      onTap: () => Get.toNamed(AppRoutes.payments),
                    ),
                  ],
                ),
              ),
            ),

            // Recent cases header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                      onPressed: () => Get.toNamed(AppRoutes.lawyerCases),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Cases list
            Obx(() {
              if (_caseCtrl.cases.isEmpty && !_caseCtrl.isLoading.value) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 44,
                              color: colorScheme.outline.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text('No cases assigned yet'),
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
                        child: _lawyerCaseCard(context, c),
                      );
                    },
                    childCount: _caseCtrl.cases.take(5).length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _lawyerCaseCard(BuildContext context, dynamic c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed('/lawyer/cases/${c.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ProfileAvatar(name: c.clientFullName, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.clientFullName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: c.status ?? 'OPEN'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ───
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Chip ───
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
