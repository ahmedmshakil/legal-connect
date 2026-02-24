import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'auth_userInfo';
  static const String _isLoggedInKey = 'auth_isLoggedIn';
  static const String _userTypeKey = 'auth_userType';
  static const String _themeKey = 'theme_isDark';

  Future<StorageService> init() async {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // User info
  Future<void> saveUserInfo(UserModel user) async {
    _prefs.setString(_userInfoKey, jsonEncode(user.toJson()));
  }

  UserModel? getUserInfo() {
    final data = _prefs.getString(_userInfoKey);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // Login state
  Future<void> setLoggedIn(bool value) async {
    _prefs.setBool(_isLoggedInKey, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // User type
  Future<void> saveUserType(String type) async {
    _prefs.setString(_userTypeKey, type);
  }

  String? getUserType() {
    return _prefs.getString(_userTypeKey);
  }

  // Theme
  Future<void> saveTheme(bool isDark) async {
    _prefs.setBool(_themeKey, isDark);
  }

  bool? getTheme() {
    return _prefs.getBool(_themeKey);
  }

  // Clear all
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
