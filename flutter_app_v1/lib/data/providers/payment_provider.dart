import 'package:dio/dio.dart';
import 'api_provider.dart';

class PaymentProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> createPayment(Map<String, dynamic> data) {
    return _dio.post('/payments/', data: data);
  }

  Future<Response> createStripeSession(String paymentId) {
    return _dio.post('/payments/$paymentId/stripe-session');
  }

  Future<Response> completePayment(String sessionId) {
    return _dio.put('/payments/complete/$sessionId');
  }

  Future<Response> getPayment(String paymentId) {
    return _dio.get('/payments/$paymentId');
  }

  Future<Response> getAllPayments({
    int page = 0,
    int size = 10,
    String sortDirection = 'DESC',
  }) {
    return _dio.get(
      '/payments/',
      queryParameters: {
        'page': page,
        'size': size,
        'sortDirection': sortDirection,
      },
    );
  }

  Future<Response> releasePayment(String paymentId) {
    return _dio.put('/payments/$paymentId/release');
  }

  Future<Response> cancelPayment(String paymentId) {
    return _dio.put('/payments/$paymentId/cancel');
  }
}
