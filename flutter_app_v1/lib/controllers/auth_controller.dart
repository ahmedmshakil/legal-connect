import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
      userInfo.value = UserModel.fromJson(authData['user']);
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
        userInfo.value = UserModel.fromJson(userData);
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
      if (picData != null) {
        userInfo.value = userInfo.value?.copyWith(
          profilePictureUrl: picData['profilePictureUrl'],
          profilePictureThumbnailUrl: picData['profilePictureThumbnailUrl'],
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
    if (e is Exception) {
      try {
        final dioError = e as dynamic;
        if (dioError.response?.data != null) {
          final data = dioError.response.data;
          if (data is Map) {
            return data['message'] ?? data['error'] ?? 'An error occurred';
          }
          return data.toString();
        }
      } catch (_) {}
    }
    return 'An error occurred. Please try again.';
  }
}
