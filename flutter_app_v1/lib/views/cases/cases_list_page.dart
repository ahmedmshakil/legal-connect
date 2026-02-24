import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/case_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../../utils/helpers.dart';

class CasesListPage extends StatefulWidget {
  const CasesListPage({super.key});

  @override
  State<CasesListPage> createState() => _CasesListPageState();
}

class _CasesListPageState extends State<CasesListPage> {
  late CaseController _ctrl;
  final _scrollCtrl = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isLawyer = auth.isLawyer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => _ctrl.setStatusFilter(v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: '', child: Text('All')),
              const PopupMenuItem(value: 'OPEN', child: Text('Open')),
              const PopupMenuItem(
                value: 'IN_PROGRESS',
                child: Text('In Progress'),
              ),
              const PopupMenuItem(value: 'RESOLVED', child: Text('Resolved')),
              const PopupMenuItem(value: 'CLOSED', child: Text('Closed')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _ctrl.getAllUserCases(reset: true),
        child: Obx(() {
          if (_ctrl.isLoading.value && _ctrl.cases.isEmpty) {
            return const ShimmerLoading();
          }
          if (_ctrl.cases.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.folder_open,
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
            padding: const EdgeInsets.all(16),
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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    final prefix = isLawyer ? '/lawyer' : '/user';
                    Get.toNamed('$prefix/cases/${c.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.title ?? 'Untitled',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            StatusBadge(label: c.status ?? 'OPEN'),
                          ],
                        ),
                        if (c.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            c.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Helpers.formatRelativeTime(c.createdAt ?? ''),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (c.lawyerFirstName != null) ...[
                              const Spacer(),
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLawyer ? c.clientFullName : c.lawyerFullName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: isLawyer
          ? null
          : FloatingActionButton(
              onPressed: () => Get.toNamed(AppRoutes.userCreateCase),
              child: const Icon(Icons.add),
            ),
    );
  }
}
