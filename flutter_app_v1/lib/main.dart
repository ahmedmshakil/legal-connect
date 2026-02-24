import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'routes/initial_binding.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage before app starts
  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);

  // Read saved theme preference before launching
  final savedDark = storage.getTheme();
  final initialMode = (savedDark == true) ? ThemeMode.dark : ThemeMode.light;

  runApp(MyApp(initialThemeMode: initialMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Legal Connect',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
    );
  }
}
