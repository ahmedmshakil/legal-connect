import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/storage_service.dart';

class ThemeController extends GetxController {
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    // React to theme changes OUTSIDE build phase
    ever(isDark, (bool dark) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
      });
    });
  }

  void _loadTheme() {
    final storage = Get.find<StorageService>();
    final saved = storage.getTheme();
    if (saved != null) {
      isDark.value = saved;
    }
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    final storage = Get.find<StorageService>();
    storage.saveTheme(isDark.value);
  }
}
