import 'package:get/get.dart';
import '../data/models/payment_model.dart';
import '../data/providers/payment_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentController extends GetxController {
  final PaymentProvider _provider = PaymentProvider();

  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final Rx<PaymentModel?> currentPayment = Rx<PaymentModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      final response = await _provider.getAllPayments();
      final data = response.data;
      final pageData = data['data'] ?? data;

      if (pageData != null) {
        // Backend returns List<PaymentResponseDTO> directly (not paginated content)
        final paymentList = pageData is List
            ? pageData
            : (pageData['content'] ?? []);
        payments.value = (paymentList as List)
            .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startStripeCheckout(String paymentId) async {
    try {
      isLoading.value = true;
      final response = await _provider.createStripeSession(paymentId);
      final data = response.data;
      final sessionData = data['data'] ?? data;
      final checkoutUrl = sessionData['checkoutUrl'] ?? sessionData['url'];

      if (checkoutUrl != null) {
        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      error.value = 'Failed to start payment';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> completePayment(String sessionId) async {
    try {
      isLoading.value = true;
      final response = await _provider.completePayment(sessionId);
      final data = response.data;
      final paymentData = data['data'] ?? data;

      if (paymentData != null && paymentData is Map<String, dynamic>) {
        currentPayment.value = PaymentModel.fromJson(paymentData);
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> releasePayment(String paymentId) async {
    try {
      await _provider.releasePayment(paymentId);
      await loadPayments();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelPayment(String paymentId) async {
    try {
      await _provider.cancelPayment(paymentId);
      await loadPayments();
      return true;
    } catch (_) {
      return false;
    }
  }
}
