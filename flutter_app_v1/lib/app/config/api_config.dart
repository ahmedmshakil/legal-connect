class ApiConfig {
  // Backend base URLs - change these for production
  static const String backendBaseUrl = 'http://10.0.2.2:8080/v1';
  static const String aiBaseUrl = 'http://10.0.2.2:8000/api/v1';

  // WebSocket URLs
  static const String wsBaseUrl = 'ws://10.0.2.2:8080/v1/ws';

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
