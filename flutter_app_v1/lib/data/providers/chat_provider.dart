import 'package:dio/dio.dart';
import 'api_provider.dart';

class ChatProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> sendMessage(Map<String, dynamic> data) {
    return _dio.post('/chat/send', data: data);
  }

  Future<Response> getConversations() {
    return _dio.get('/chat/conversations');
  }

  Future<Response> getConversationMessages(
    String conversationId, {
    int page = 0,
    int size = 20,
  }) {
    return _dio.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<Response> markConversationAsRead(String conversationId) {
    return _dio.put('/chat/conversations/$conversationId/read');
  }

  Future<Response> getUnreadCount() {
    return _dio.get('/chat/unread-count');
  }
}
