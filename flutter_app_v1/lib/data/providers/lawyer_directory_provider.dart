import 'package:dio/dio.dart';
import 'api_provider.dart';

class LawyerDirectoryProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> findLawyers({
    int page = 0,
    int size = 10,
    String sortDirection = 'DESC',
    Map<String, dynamic>? filters,
  }) {
    final data = <String, dynamic>{
      'page': page,
      'size': size,
      'sortDirection': sortDirection,
      ...?filters,
    };
    return _dio.post('/lawyer-directory/find-lawyers', data: data);
  }

  Future<Response> addReview(Map<String, dynamic> data) {
    return _dio.post('/lawyer-directory/reviews', data: data);
  }

  Future<Response> updateReview(String reviewId, Map<String, dynamic> data) {
    return _dio.put('/lawyer-directory/reviews/$reviewId', data: data);
  }

  Future<Response> deleteReview(String reviewId) {
    return _dio.delete('/lawyer-directory/reviews/$reviewId');
  }

  Future<Response> getReviewByCaseId(String caseId) {
    return _dio.get('/lawyer-directory/reviews/$caseId');
  }

  Future<Response> getLawyerReviews(String lawyerId) {
    return _dio.get('/lawyer-directory/lawyers/$lawyerId/reviews');
  }
}
