import 'package:dio/dio.dart';
import 'api_provider.dart';

class CaseProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> getAllUserCases({
    int page = 0,
    int size = 10,
    String? status,
    String sortDirection = 'DESC',
  }) {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortDirection': sortDirection,
    };
    if (status != null) params['status'] = status;
    return _dio.get('/case/', queryParameters: params);
  }

  Future<Response> getCaseById(String caseId) {
    return _dio.get('/case/$caseId');
  }

  Future<Response> createCase(Map<String, dynamic> data) {
    return _dio.post('/case/', data: data);
  }

  Future<Response> updateCase(String caseId, Map<String, dynamic> data) {
    return _dio.put('/case/$caseId', data: data);
  }

  Future<Response> updateCaseStatus(String caseId, Map<String, dynamic> data) {
    return _dio.put('/case/$caseId/status', data: data);
  }
}
