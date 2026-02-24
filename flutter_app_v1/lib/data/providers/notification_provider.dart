import 'package:dio/dio.dart';
import 'api_provider.dart';

class NotificationProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> getNotifications({
    int page = 0,
    int size = 10,
    bool? unreadOnly,
  }) {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (unreadOnly != null) params['unreadOnly'] = unreadOnly;
    return _dio.get('/notifications/', queryParameters: params);
  }

  Future<Response> getUnreadCount() {
    return _dio.get('/notifications/unread-count');
  }

  Future<Response> markAsRead(String notificationId) {
    return _dio.put('/notifications/$notificationId/read');
  }

  Future<Response> markAllAsRead() {
    return _dio.put('/notifications/mark-all-read');
  }

  Future<Response> getPreferences() {
    return _dio.get('/notifications/preferences');
  }

  Future<Response> updatePreference(String type, Map<String, dynamic> data) {
    return _dio.put('/notifications/preferences/$type', data: data);
  }
}
