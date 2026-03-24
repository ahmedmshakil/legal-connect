import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _backendPath = '/v1';
  static const String _aiPath = '/api/v1';
  static const int _defaultBackendPort = 8080;
  static const int _defaultAiPort = 8000;

  static String get backendScheme {
    const configured = String.fromEnvironment(
      'LC_BACKEND_SCHEME',
      defaultValue: 'http',
    );
    return configured.trim().toLowerCase();
  }

  static String get backendHost => resolveHost(
    overrideHost: const String.fromEnvironment('LC_BACKEND_HOST'),
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  );

  static int get backendPort => const int.fromEnvironment(
    'LC_BACKEND_PORT',
    defaultValue: _defaultBackendPort,
  );

  static String get aiScheme {
    const configured = String.fromEnvironment(
      'LC_AI_SCHEME',
      defaultValue: 'http',
    );
    return configured.trim().toLowerCase();
  }

  static String get aiHost {
    const configured = String.fromEnvironment('LC_AI_HOST');
    if (configured.trim().isNotEmpty) {
      return configured.trim();
    }
    return backendHost;
  }

  static int get aiPort =>
      const int.fromEnvironment('LC_AI_PORT', defaultValue: _defaultAiPort);

  @visibleForTesting
  static String resolveHost({
    required String overrideHost,
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    final trimmedOverride = overrideHost.trim();
    if (trimmedOverride.isNotEmpty) {
      return trimmedOverride;
    }

    if (isWeb) {
      return 'localhost';
    }

    switch (platform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return 'localhost';
    }
  }

  @visibleForTesting
  static String resolveWebSocketScheme(String scheme) {
    return scheme.trim().toLowerCase() == 'https' ? 'wss' : 'ws';
  }

  static Uri _buildUri({
    required String scheme,
    required String host,
    required int port,
    required String path,
  }) {
    return Uri(scheme: scheme, host: host, port: port, path: path);
  }

  // Backend base URLs
  static String get backendBaseUrl => _buildUri(
    scheme: backendScheme,
    host: backendHost,
    port: backendPort,
    path: _backendPath,
  ).toString();

  static String get aiBaseUrl => _buildUri(
    scheme: aiScheme,
    host: aiHost,
    port: aiPort,
    path: _aiPath,
  ).toString();

  // WebSocket URL
  static String get wsBaseUrl => _buildUri(
    scheme: resolveWebSocketScheme(backendScheme),
    host: backendHost,
    port: backendPort,
    path: '$_backendPath/ws',
  ).toString();

  // Timeouts
  static const int connectTimeout = 60000; // 60s
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 30000;

  // Retry config
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // ms

  // Pagination defaults
  static const int defaultPageSize = 10;
  static const String defaultSortDirection = 'DESC';
}
