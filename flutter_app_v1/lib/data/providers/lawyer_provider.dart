import 'package:dio/dio.dart';
import 'api_provider.dart';

class LawyerProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> getLawyerInfo({String? email}) {
    final params = <String, dynamic>{};
    if (email != null) params['email'] = email;
    return _dio.get('/lawyer/profile', queryParameters: params);
  }

  Future<Response> createLawyerProfile(Map<String, dynamic> data) {
    return _dio.post('/lawyer/profile', data: data);
  }

  Future<Response> updateLawyerProfile(Map<String, dynamic> data) {
    return _dio.put('/lawyer/profile', data: data);
  }

  Future<Response> uploadCredentials(String filePath) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(filePath),
    });
    return _dio.post('/lawyer/upload-credentials', data: formData);
  }

  Future<Response> viewCredentials({String? email}) {
    final params = <String, dynamic>{};
    if (email != null) params['email'] = email;
    return _dio.get(
      '/lawyer/view-credentials',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
  }

  // Availability slots
  Future<Response> getAvailabilitySlots({String? email}) {
    final params = <String, dynamic>{};
    if (email != null) params['email'] = email;
    return _dio.get('/lawyer/availability-slots', queryParameters: params);
  }

  Future<Response> createAvailabilitySlot(Map<String, dynamic> data) {
    return _dio.post('/lawyer/availability-slots', data: data);
  }

  Future<Response> updateAvailabilitySlot(
    String slotId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('/lawyer/availability-slots/$slotId', data: data);
  }

  Future<Response> deleteAvailabilitySlot(String slotId) {
    return _dio.delete('/lawyer/availability-slots/$slotId');
  }

  Future<Response> updateHourlyCharge(double charge) {
    return _dio.put('/lawyer/hourly-charge', data: {'hourlyCharge': charge});
  }
}
