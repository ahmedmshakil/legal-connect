import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/animated_list_item.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/helpers.dart';

class CasesListPage extends StatefulWidget {
  const CasesListPage({super.key});

  @override
  State<CasesListPage> createState() => _CasesListPageState();
}

class _CasesListPageState extends State<CasesListPage> {
  late CaseController _ctrl;
  final _scrollCtrl = ScrollController();
  String _selectedFilter = '';

  static const _filters = ['', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];
  static const _filterLabels = ['All', 'Open', 'In Progress', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(CaseController());
    _ctrl.getAllUserCases(reset: true);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_ctrl.isLoading.value && _ctrl.hasMorePages) {
        _ctrl.loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

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
    final auth = Get.find<AuthController>();
    final isLawyer = auth.isLawyer;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final isSelected = _selectedFilter == _filters[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_filterLabels[i]),
                    onSelected: (_) {
                      setState(() => _selectedFilter = _filters[i]);
                      _ctrl.setStatusFilter(_filters[i]);
                    },
                    selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                    checkmarkColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    side: isSelected
                        ? BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.3))
                        : BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          // Cases
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _ctrl.getAllUserCases(reset: true),
              child: Obx(() {
                if (_ctrl.isLoading.value && _ctrl.cases.isEmpty) {
                  return const ShimmerLoading();
                }
                if (_ctrl.cases.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.folder_open_rounded,
                    title: 'No Cases Found',
                    subtitle: isLawyer
                        ? 'Cases assigned to you will appear here'
                        : 'Create a new case to get started',
                    actionLabel: isLawyer ? null : 'Create Case',
                    onAction: isLawyer
                        ? null
                        : () => Get.toNamed(AppRoutes.userCreateCase),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: _ctrl.cases.length + (_ctrl.hasMorePages ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _ctrl.cases.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final c = _ctrl.cases[i];
                    return AnimatedListItem(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final prefix = isLawyer ? '/lawyer' : '/user';
                              Get.toNamed('$prefix/cases/${c.id}');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: _statusColor(c.status),
                                      width: 3.5),
                                ),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(14, 14, 16, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.title ?? 'Untitled',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      StatusBadge(label: c.status ?? 'OPEN'),
                                    ],
                                  ),
                                  if (c.description != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      c.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: colorScheme.outline),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 13,
                                          color: colorScheme.outline),
                                      const SizedBox(width: 4),
                                      Text(
                                        Helpers.formatRelativeTime(
                                            c.createdAt ?? ''),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: colorScheme.outline),
                                      ),
                                      if (c.lawyerFirstName != null) ...[
                                        const Spacer(),
                                        Icon(Icons.person_outline_rounded,
                                            size: 13,
                                            color: colorScheme.outline),
                                        const SizedBox(width: 4),
                                        Text(
                                          isLawyer
                                              ? c.clientFullName
                                              : c.lawyerFullName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: colorScheme.outline),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: isLawyer
          ? null
          : FloatingActionButton(
              onPressed: () => Get.toNamed(AppRoutes.userCreateCase),
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}
