import 'package:dio/dio.dart';
import 'api_provider.dart';

class ScheduleProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> getAllUserSchedules({
    int page = 0,
    int size = 10,
    String sortDirection = 'DESC',
  }) {
    return _dio.get(
      '/schedule/',
      queryParameters: {
        'page': page,
        'size': size,
        'sortDirection': sortDirection,
      },
    );
  }

  Future<Response> getSchedulesForCase(String caseId) {
    return _dio.get('/schedule/case/$caseId');
  }

  Future<Response> getScheduleById(String scheduleId) {
    return _dio.get('/schedule/$scheduleId');
  }

  Future<Response> createSchedule(Map<String, dynamic> data) {
    return _dio.post('/schedule/', data: data);
  }

  Future<Response> updateSchedule(
    String scheduleId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('/schedule/$scheduleId', data: data);
  }

  Future<Response> deleteSchedule(String scheduleId) {
    return _dio.delete('/schedule/$scheduleId');
  }
}
