import 'package:dio/dio.dart';
import 'api_provider.dart';

class AuthProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> login(String email, String password) {
    return _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) {
    return _dio.post(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  Future<Response> sendVerificationCode(String email) {
    return _dio.post('/auth/send-verification-code', data: {'email': email});
  }

  Future<Response> verifyEmail(String email, String code) {
    return _dio.post(
      '/auth/verify-email',
      data: {'email': email, 'code': code},
    );
  }

  Future<Response> resetPassword(
    String email,
    String code,
    String newPassword,
  ) {
    return _dio.post(
      '/auth/reset-password',
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }

  Future<Response> changePassword(String oldPassword, String newPassword) {
    return _dio.put(
      '/user/change-password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  Future<Response> logout() {
    return _dio.post('/user/logout');
  }

  Future<Response> getUserInfo() {
    return _dio.get('/user/user-info');
  }

  Future<Response> uploadProfilePicture(String filePath) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(filePath),
    });
    return _dio.post('/user/profile-picture', data: formData);
  }
}
