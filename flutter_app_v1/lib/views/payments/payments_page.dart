import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/status_badge.dart';
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
              icon: Icons.payment_outlined,
              title: 'No Payments',
              subtitle: 'Payment history will appear here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _ctrl.payments.length,
            itemBuilder: (_, i) {
              final p = _ctrl.payments[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Helpers.formatCurrency(p.amount ?? 0),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          StatusBadge(label: p.status ?? 'PENDING'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${p.payerName ?? ''} → ${p.payeeName ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Helpers.formatDate(p.createdAt ?? ''),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (p.status == 'PENDING') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _ctrl.startStripeCheckout(p.id ?? ''),
                            child: const Text('Pay Now'),
                          ),
                        ),
                      ],
                    ],
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
