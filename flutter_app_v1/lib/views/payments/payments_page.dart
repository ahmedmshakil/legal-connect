import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/animated_list_item.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/helpers.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late PaymentController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(PaymentController());
    _ctrl.loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: RefreshIndicator(
        onRefresh: () async => _ctrl.loadPayments(),
        child: Obx(() {
          if (_ctrl.isLoading.value && _ctrl.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_ctrl.payments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.payment_rounded,
              title: 'No Payments',
              subtitle: 'Payment history will appear here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: _ctrl.payments.length,
            itemBuilder: (_, i) {
              final p = _ctrl.payments[i];
              return AnimatedListItem(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (p.status == 'PAID'
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  p.status == 'PAID'
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_rounded,
                                  color: p.status == 'PAID'
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Helpers.formatCurrency(p.amount ?? 0),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.payerName ?? ''} → ${p.payeeName ?? ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: colorScheme.outline),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(label: p.status ?? 'PENDING'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 13, color: colorScheme.outline),
                              const SizedBox(width: 4),
                              Text(
                                Helpers.formatDate(p.createdAt ?? ''),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: colorScheme.outline,
                                        fontSize: 11),
                              ),
                            ],
                          ),
                          if (p.status == 'PENDING') ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _ctrl.startStripeCheckout(p.id ?? ''),
                                icon: const Icon(Icons.payment_rounded,
                                    size: 18),
                                label: const Text('Pay Now'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
