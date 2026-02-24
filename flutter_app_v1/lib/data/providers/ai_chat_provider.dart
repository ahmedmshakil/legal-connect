import 'package:dio/dio.dart';
import 'api_provider.dart';

class AiChatProvider {
  final Dio _dio = ApiProvider().aiDio;

  Future<Response> sendMessage({
    required String message,
    String? sessionId,
    int? contextLimit,
  }) {
    return _dio.post(
      '/chat',
      data: {
        'message': message,
        'session_id': ?sessionId,
        'context_limit': ?contextLimit,
      },
    );
  }

  Future<Response> searchDocuments({
    required String query,
    int topK = 5,
    double threshold = 0.3,
  }) {
    return _dio.post(
      '/search',
      data: {'query': query, 'top_k': topK, 'threshold': threshold},
    );
  }

  Future<Response> createSession({String? title}) {
    return _dio.post('/sessions', data: {'title': ?title});
  }

  Future<Response> getSessionInfo(String sessionId) {
    return _dio.get('/sessions/$sessionId');
  }

  Future<Response> getChatHistory(String sessionId) {
    return _dio.get('/sessions/$sessionId/history');
  }

  Future<Response> getUserSessions(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _dio.get(
      '/sessions',
      queryParameters: {'limit': limit, 'offset': offset},
    );
  }

  Future<Response> updateSession(String sessionId, Map<String, dynamic> data) {
    return _dio.put('/sessions/$sessionId', data: data);
  }

  Future<Response> deleteSession(String sessionId) {
    return _dio.delete('/sessions/$sessionId');
  }

  Future<Response> getSessionMessages(
    String sessionId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _dio.get(
      '/sessions/$sessionId/messages',
      queryParameters: {'limit': limit, 'offset': offset},
    );
  }

  Future<Response> uploadDocument(String sessionId, String filePath) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(filePath),
    });
    return _dio.post('/sessions/$sessionId/upload-document', data: formData);
  }

  Future<Response> getSessionDocuments(String sessionId) {
    return _dio.get('/sessions/$sessionId/documents');
  }

  Future<Response> deleteSessionDocument(String sessionId, String documentId) {
    return _dio.delete('/sessions/$sessionId/documents/$documentId');
  }

  Future<Response> searchSessionDocuments(
    String sessionId, {
    required String query,
    int topK = 5,
    double threshold = 0.3,
  }) {
    return _dio.post(
      '/sessions/$sessionId/search-documents',
      data: {'query': query, 'top_k': topK, 'threshold': threshold},
    );
  }

  Future<Response> checkHealth() {
    return _dio.get('/health');
  }
}
