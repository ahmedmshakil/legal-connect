import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../app/config/api_config.dart';
import '../services/storage_service.dart';

class ApiProvider {
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;
  ApiProvider._internal();

  late Dio dio;
  late Dio aiDio;

  void init() {
    dio = _createDio(ApiConfig.backendBaseUrl);
    aiDio = _createDio(ApiConfig.aiBaseUrl);
  }

  Dio _createDio(String baseUrl) {
    final d = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // JWT token interceptor
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = Get.find<StorageService>();
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid — logout
            try {
              final storage = Get.find<StorageService>();
              await storage.clearAll();
              Get.offAllNamed('/login');
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );

    // Retry interceptor
    d.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode ?? 0;
          if (statusCode >= 500 && statusCode < 600) {
            // Retry up to 3 times with exponential backoff
            final options = error.requestOptions;
            final retryCount = options.extra['retryCount'] ?? 0;
            if (retryCount < ApiConfig.maxRetries) {
              options.extra['retryCount'] = retryCount + 1;
              await Future.delayed(
                Duration(
                  milliseconds: (ApiConfig.retryDelay * (retryCount + 1))
                      .toInt(),
                ),
              );
              try {
                final response = await d.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    return d;
  }
}
