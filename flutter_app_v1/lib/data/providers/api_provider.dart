import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
          _logRequest(options);
          final storage = Get.find<StorageService>();
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logError(error);

          final isAuthEndpoint =
              error.requestOptions.path.startsWith('/auth/') ||
              error.requestOptions.path.contains('/auth/');

          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            // Token expired or invalid — logout
            try {
              final storage = Get.find<StorageService>();
              final token = await storage.getToken();
              if (token != null && token.isNotEmpty) {
                await storage.clearAll();
                Get.offAllNamed('/login');
              }
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

  void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] ${options.method} ${options.uri} '
      'base=${options.baseUrl.isEmpty ? 'n/a' : options.baseUrl}',
    );
  }

  void _logResponse(Response response) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
    );
  }

  void _logError(DioException error) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] ERROR ${error.type} ${error.requestOptions.method} '
      '${error.requestOptions.uri} '
      'status=${error.response?.statusCode} '
      'message=${error.message}',
    );
  }
}
