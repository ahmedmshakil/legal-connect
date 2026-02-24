import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lawyer_search_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/empty_state_widget.dart';

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
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Lawyers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Specialization'),
                initialValue: _ctrl.specialization.value.isNotEmpty
                    ? _ctrl.specialization.value
                    : null,
                items: AppConstants.specializations
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _ctrl.specialization.value = v ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Court'),
                initialValue: _ctrl.practicingCourt.value.isNotEmpty
                    ? _ctrl.practicingCourt.value
                    : null,
                items: AppConstants.courts
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => _ctrl.practicingCourt.value = v ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Division'),
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
              const SizedBox(height: 12),
              Obx(() {
                final districts = _ctrl.division.value.isNotEmpty
                    ? AppConstants.districtsByDivision[_ctrl.division.value] ??
                          []
                    : <String>[];
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'District'),
                  initialValue: _ctrl.district.value.isNotEmpty
                      ? _ctrl.district.value
                      : null,
                  items: districts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => _ctrl.district.value = v ?? '',
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Min Exp (yrs)',
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
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          _ctrl.maxExperience.value = int.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Lawyers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
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
            icon: Icons.search,
            title: 'Search for Lawyers',
            subtitle: 'Use filters to find lawyers matching your needs',
            actionLabel: 'Set Filters',
            onAction: _showFilters,
          );
        }
        if (_ctrl.lawyers.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.person_search,
            title: 'No Lawyers Found',
            subtitle: 'Try adjusting your filters',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _ctrl.lawyers.length,
          itemBuilder: (_, i) {
            final l = _ctrl.lawyers[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => Get.toNamed('/user/lawyers/${l.id}'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        name: l.fullName,
                        imageUrl: l.profilePictureUrl,
                        radius: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.fullName,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (l.firm != null)
                              Text(
                                l.firm!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (l.yearsOfExperience != null) ...[
                                  Icon(
                                    Icons.work,
                                    size: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${l.yearsOfExperience}y',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (l.averageRating != null) ...[
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    l.averageRating!.toStringAsFixed(1),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                            if (l.specializations != null &&
                                l.specializations!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: l.specializations!
                                    .take(3)
                                    .map(
                                      (s) => Chip(
                                        label: Text(
                                          s,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (l.hourlyCharge != null)
                        Column(
                          children: [
                            Text(
                              '৳${l.hourlyCharge!.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              '/hr',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
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
    );
  }
}
