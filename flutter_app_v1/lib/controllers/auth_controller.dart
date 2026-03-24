import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../app/config/api_config.dart';
import '../data/models/user_model.dart';
import '../data/providers/auth_provider.dart';
import '../data/services/storage_service.dart';
import '../data/services/websocket_service.dart';
import '../data/services/chat_websocket_service.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final Rx<UserModel?> userInfo = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxString userType = ''.obs;
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isUser => userType.value.toUpperCase() == 'USER';
  bool get isLawyer => userType.value.toUpperCase() == 'LAWYER';
  bool get isAdmin => userType.value.toUpperCase() == 'ADMIN';
  String get userId => userInfo.value?.id ?? '';
  String get userEmail => userInfo.value?.email ?? '';
  bool get isEmailVerified => userInfo.value?.emailVerified ?? false;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final storage = Get.find<StorageService>();
    final stored = storage.isLoggedIn();
    if (stored) {
      final savedToken = await storage.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        // Check if token is expired
        if (JwtDecoder.isExpired(savedToken)) {
          await clearAuth();
          return;
        }
        token.value = savedToken;
        isLoggedIn.value = true;
        userType.value = storage.getUserType() ?? '';
        userInfo.value = storage.getUserInfo();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authProvider.login(email, password);
      final data = response.data;

      // Backend returns: {"data": {"token": ...}, "status": 200, "message": ...}
      final authData = data['data'] ?? data;
      final tokenValue = authData['token'] ?? data['token'];

      if (tokenValue != null) {
        await _saveAuth(tokenValue, authData);
        await fetchUserInfo();
        _connectWebSockets();
        return true;
      }

      error.value = data['message'] ?? 'Login failed';
      return false;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authProvider.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );
      final data = response.data;

      // Backend returns: {"data": {"token": ...}, "status": 201, "message": ...}
      final authData = data['data'] ?? data;
      final tokenValue = authData['token'] ?? data['token'];

      if (tokenValue != null) {
        await _saveAuth(tokenValue, authData);
        await fetchUserInfo();
        return true;
      }

      error.value = data['message'] ?? 'Registration failed';
      return false;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveAuth(
    String tokenValue,
    Map<String, dynamic> authData,
  ) async {
    final storage = Get.find<StorageService>();
    token.value = tokenValue;
    await storage.saveToken(tokenValue);

    // Decode JWT for role
    final decoded = JwtDecoder.decode(tokenValue);
    final role = decoded['role'] ?? authData['role'] ?? '';
    userType.value = role.toString().toUpperCase();
    await storage.saveUserType(userType.value);

    isLoggedIn.value = true;
    await storage.setLoggedIn(true);

    // Save user from authData if available
    if (authData['user'] != null) {
      userInfo.value =
          UserModel.fromJson(
            Map<String, dynamic>.from(authData['user']),
          ).withFallback(
            UserModel(
              id: decoded['userId']?.toString(),
              email: decoded['sub'],
              role: userType.value,
              firstName: decoded['firstName'],
              lastName: decoded['lastName'],
              emailVerified: decoded['emailVerified'],
            ),
          );
    } else {
      userInfo.value = UserModel(
        id: decoded['userId']?.toString(),
        email: decoded['sub'],
        role: userType.value,
        firstName: decoded['firstName'],
        lastName: decoded['lastName'],
        emailVerified: decoded['emailVerified'],
      );
    }
    await storage.saveUserInfo(userInfo.value!);
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await _authProvider.getUserInfo();
      final data = response.data;
      final userData = data['data'] ?? data;
      if (userData != null && userData is Map<String, dynamic>) {
        final fetchedUser = UserModel.fromJson(userData);
        final mergedUser = fetchedUser.withFallback(userInfo.value);
        userInfo.value = mergedUser;
        userType.value = (userInfo.value?.role ?? userType.value).toUpperCase();

        final storage = Get.find<StorageService>();
        await storage.saveUserInfo(userInfo.value!);
        await storage.saveUserType(userType.value);
      }
    } catch (_) {}
  }

  Future<bool> sendVerificationCode(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authProvider.sendVerificationCode(email);
      return true;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authProvider.verifyEmail(email, code);
      // Refresh user info
      await fetchUserInfo();
      return true;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authProvider.resetPassword(email, code, newPassword);
      return true;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authProvider.changePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadProfilePicture(String filePath) async {
    try {
      isLoading.value = true;
      final response = await _authProvider.uploadProfilePicture(filePath);
      final data = response.data;
      final picData = data['data'] ?? data;
      if (picData != null && picData is Map) {
        final normalizedPicture = UserModel.fromJson({
          'profilePicture': Map<String, dynamic>.from(picData),
        });
        userInfo.value = userInfo.value?.copyWith(
          profilePictureUrl: normalizedPicture.profilePictureUrl,
          profilePictureThumbnailUrl:
              normalizedPicture.profilePictureThumbnailUrl,
        );
        final storage = Get.find<StorageService>();
        if (userInfo.value != null) {
          await storage.saveUserInfo(userInfo.value!);
        }
      }
      return true;
    } catch (e) {
      error.value = _extractError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (_) {}
    await clearAuth();
    Get.offAllNamed('/login');
  }

  Future<void> clearAuth() async {
    _disconnectWebSockets();
    final storage = Get.find<StorageService>();
    await storage.clearAll();
    token.value = '';
    isLoggedIn.value = false;
    userType.value = '';
    userInfo.value = null;
  }

  void _connectWebSockets() {
    try {
      Get.find<WebSocketService>().connect();
      Get.find<ChatWebSocketService>().connect();
    } catch (_) {}
  }

  void _disconnectWebSockets() {
    try {
      Get.find<WebSocketService>().disconnect();
      Get.find<ChatWebSocketService>().disconnect();
    } catch (_) {}
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final nestedError = data['error'];
        if (nestedError is Map && nestedError['message'] != null) {
          return nestedError['message'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Could not reach the Legal Connect backend at '
            '${ApiConfig.backendBaseUrl}. '
            'Android emulator should use 10.0.2.2. '
            'On a physical device, run Flutter with '
            '--dart-define=LC_BACKEND_HOST=<YOUR_COMPUTER_LAN_IP>.';
      }

      if (e.message != null && e.message!.trim().isNotEmpty) {
        return e.message!;
      }

      return 'Request failed while talking to ${ApiConfig.backendBaseUrl}.';
    }

    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return 'An error occurred. Please try again.';
  }
}
