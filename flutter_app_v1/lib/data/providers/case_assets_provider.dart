import 'package:dio/dio.dart';
import 'api_provider.dart';

class CaseAssetsProvider {
  final Dio _dio = ApiProvider().dio;

  // Notes
  Future<Response> getAllNotesForCase(
    String caseId, {
    int page = 0,
    int size = 10,
    String sortDirection = 'DESC',
  }) {
    return _dio.get(
      '/case-assets/cases/$caseId/notes',
      queryParameters: {
        'page': page,
        'size': size,
        'sortDirection': sortDirection,
      },
    );
  }

  Future<Response> getNoteById(String noteId) {
    return _dio.get('/case-assets/notes/$noteId');
  }

  Future<Response> createNote(Map<String, dynamic> data) {
    return _dio.post('/case-assets/notes', data: data);
  }

  Future<Response> updateNote(String noteId, Map<String, dynamic> data) {
    return _dio.put('/case-assets/notes/$noteId', data: data);
  }

  Future<Response> deleteNote(String noteId) {
    return _dio.delete('/case-assets/notes/$noteId');
  }

  // Documents
  Future<Response> getAllDocumentsForCase(
    String caseId, {
    int page = 0,
    int size = 10,
    String sortDirection = 'DESC',
  }) {
    return _dio.get(
      '/case-assets/cases/$caseId/documents',
      queryParameters: {
        'page': page,
        'size': size,
        'sortDirection': sortDirection,
      },
    );
  }

  Future<Response> uploadDocument({
    required String caseId,
    required String title,
    required String description,
    required String privacy,
    required String filePath,
  }) {
    final formData = FormData.fromMap({
      'caseId': caseId,
      'title': title,
      'description': description,
      'privacy': privacy,
      'file': MultipartFile.fromFileSync(filePath),
    });
    return _dio.post('/case-assets/documents', data: formData);
  }

  Future<Response> updateDocument(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('/case-assets/documents/$documentId', data: data);
  }

  Future<Response> deleteDocument(String documentId) {
    return _dio.delete('/case-assets/documents/$documentId');
  }

  Future<Response> viewDocument(String documentId) {
    return _dio.get(
      '/case-assets/documents/$documentId/view',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  Future<Response> getMyDocuments() {
    return _dio.get('/case-assets/users/me/documents');
  }

  Future<Response> getMyVisibleDocuments() {
    return _dio.get('/case-assets/users/me/documents/visible');
  }
}
