import 'package:dio/dio.dart';
import 'api_provider.dart';

class MeetingProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> getMeetings() {
    return _dio.get('/videocalls/');
  }

  Future<Response> getMeeting(String meetingId) {
    return _dio.get('/videocalls/$meetingId');
  }

  Future<Response> scheduleMeeting(Map<String, dynamic> data) {
    return _dio.post('/videocalls/', data: data);
  }

  Future<Response> updateMeeting(Map<String, dynamic> data) {
    return _dio.put('/videocalls/', data: data);
  }

  Future<Response> deleteMeeting(String meetingId) {
    return _dio.delete('/videocalls/$meetingId');
  }

  Future<Response> generateMeetingToken(String meetingId) {
    return _dio.get('/videocalls/$meetingId/token');
  }
}
