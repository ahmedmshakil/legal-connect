import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lawyer_search_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/animated_list_item.dart';
import '../../app/theme/app_colors.dart';

class FindLawyersPage extends StatefulWidget {
  const FindLawyersPage({super.key});

  @override
  State<FindLawyersPage> createState() => _FindLawyersPageState();
}

class _FindLawyersPageState extends State<FindLawyersPage> {
  late LawyerSearchController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(LawyerSearchController());
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filter Lawyers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                initialValue: _ctrl.specialization.value.isNotEmpty
                    ? _ctrl.specialization.value
                    : null,
                items: AppConstants.specializations
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => _ctrl.specialization.value = v ?? '',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Court',
                  prefixIcon: Icon(Icons.gavel_rounded),
                ),
                initialValue: _ctrl.practicingCourt.value.isNotEmpty
                    ? _ctrl.practicingCourt.value
                    : null,
                items: AppConstants.courts
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => _ctrl.practicingCourt.value = v ?? '',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Division',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                initialValue: _ctrl.division.value.isNotEmpty
                    ? _ctrl.division.value
                    : null,
                items: AppConstants.divisions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) {
                  _ctrl.division.value = v ?? '';
                  _ctrl.district.value = '';
                },
              ),
              const SizedBox(height: 14),
              Obx(() {
                final districts = _ctrl.division.value.isNotEmpty
                    ? AppConstants.districtsByDivision[_ctrl.division.value] ??
                          []
                    : <String>[];
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  initialValue: _ctrl.district.value.isNotEmpty
                      ? _ctrl.district.value
                      : null,
                  items: districts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => _ctrl.district.value = v ?? '',
                );
              }),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Min Exp (yrs)',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          _ctrl.minExperience.value = int.tryParse(v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Max Exp (yrs)',
                        prefixIcon: Icon(Icons.work_history_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          _ctrl.maxExperience.value = int.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _ctrl.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _ctrl.searchLawyers(reset: true);
                      },
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Lawyers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value && _ctrl.lawyers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!_ctrl.searched.value) {
          return EmptyStateWidget(
            icon: Icons.search_rounded,
            title: 'Search for Lawyers',
            subtitle: 'Use filters to find lawyers matching your needs',
            actionLabel: 'Set Filters',
            onAction: _showFilters,
          );
        }
        if (_ctrl.lawyers.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.person_search_rounded,
            title: 'No Lawyers Found',
            subtitle: 'Try adjusting your filters',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: _ctrl.lawyers.length,
          itemBuilder: (_, i) {
            final l = _ctrl.lawyers[i];
            return AnimatedListItem(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Get.toNamed(
                      '/user/lawyers/${l.email ?? l.id}',
                      arguments: {'lawyerId': l.id, 'email': l.email},
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ProfileAvatar(
                            name: l.fullName,
                            imageUrl: l.profilePictureUrl,
                            radius: 26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (l.firm != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    l.firm!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: colorScheme.outline),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (l.yearsOfExperience != null) ...[
                                      Icon(Icons.work_outline_rounded,
                                          size: 14,
                                          color: colorScheme.outline),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${l.yearsOfExperience}y',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: colorScheme.outline),
                                      ),
                                      const SizedBox(width: 14),
                                    ],
                                    if (l.averageRating != null) ...[
                                      const Icon(Icons.star_rounded,
                                          size: 14, color: Color(0xFFF59E0B)),
                                      const SizedBox(width: 3),
                                      Text(
                                        l.averageRating!.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ],
                                ),
                                if (l.specializations != null &&
                                    l.specializations!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: l.specializations!
                                        .take(3)
                                        .map(
                                          (s) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (l.hourlyCharge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '৳${l.hourlyCharge!.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    '/hr',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
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
    );
  }
}
