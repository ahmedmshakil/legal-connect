import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lawyer_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/loading_widget.dart';
import '../../routes/app_routes.dart';

class LawyerProfilePage extends StatefulWidget {
  const LawyerProfilePage({super.key});

  @override
  State<LawyerProfilePage> createState() => _LawyerProfilePageState();
}

class _LawyerProfilePageState extends State<LawyerProfilePage> {
  late LawyerController _ctrl;
  late ReviewController _reviewCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(LawyerController());
    _reviewCtrl = Get.put(ReviewController());
    final id = Get.parameters['id'];
    if (id != null) {
      _ctrl.fetchLawyerInfo(email: id);
      _reviewCtrl.fetchLawyerReviews(id);
    } else {
      _ctrl.fetchLawyerInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Profile')),
      body: Obx(() {
        if (_ctrl.isLoading.value) return const LoadingWidget();
        final l = _ctrl.lawyerInfo.value;
        if (l == null) {
          return const Center(child: Text('Profile not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        name: l.fullName,
                        imageUrl: l.profilePictureUrl,
                        radius: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (l.firm != null)
                        Text(
                          l.firm!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (l.yearsOfExperience != null)
                            _statChip(
                              context,
                              '${l.yearsOfExperience} yrs',
                              'Experience',
                            ),
                          if (l.averageRating != null)
                            _statChip(
                              context,
                              l.averageRating!.toStringAsFixed(1),
                              'Rating',
                            ),
                          if (l.totalReviews != null)
                            _statChip(context, '${l.totalReviews}', 'Reviews'),
                          if (l.hourlyCharge != null)
                            _statChip(
                              context,
                              '৳${l.hourlyCharge!.toStringAsFixed(0)}',
                              '/Hour',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(l.bio ?? 'No bio provided'),
                      const Divider(height: 24),
                      if (l.practicingCourt != null)
                        _detailItem(
                          context,
                          Icons.gavel,
                          'Court',
                          l.practicingCourt!,
                        ),
                      if (l.division != null)
                        _detailItem(
                          context,
                          Icons.location_on,
                          'Location',
                          '${l.district ?? ''}, ${l.division!}',
                        ),
                      if (l.barCertificateNumber != null)
                        _detailItem(
                          context,
                          Icons.badge,
                          'Bar Certificate',
                          l.barCertificateNumber!,
                        ),
                    ],
                  ),
                ),
              ),
              if (l.specializations != null &&
                  l.specializations!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Specializations',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: l.specializations!
                              .map((s) => Chip(label: Text(s)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Reviews
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (_reviewCtrl.lawyerReviews.isEmpty) {
                          return const Text('No reviews yet');
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviewCtrl.lawyerReviews.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (_, i) {
                            final r = _reviewCtrl.lawyerReviews[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ProfileAvatar(
                                name: r.reviewerFullName,
                                radius: 18,
                              ),
                              title: Row(
                                children: [
                                  Text(r.reviewerFullName),
                                  const Spacer(),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (idx) => Icon(
                                        idx < (r.rating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: r.comment != null
                                  ? Text(r.comment!)
                                  : null,
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Contact button (for users viewing lawyer profile)
              if (!Get.find<AuthController>().isLawyer) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.chat),
                    icon: const Icon(Icons.chat),
                    label: const Text('Contact Lawyer'),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _statChip(BuildContext context, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _detailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
