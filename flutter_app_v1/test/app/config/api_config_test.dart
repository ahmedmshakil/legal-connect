import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_v1/app/config/api_config.dart';

void main() {
  group('ApiConfig.resolveHost', () {
    test('uses Android emulator host by default on Android', () {
      final host = ApiConfig.resolveHost(
        overrideHost: '',
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(host, '10.0.2.2');
    });

    test('prefers explicit host override', () {
      final host = ApiConfig.resolveHost(
        overrideHost: '192.168.0.55',
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(host, '192.168.0.55');
    });

    test('uses localhost for iOS and desktop style targets', () {
      final iosHost = ApiConfig.resolveHost(
        overrideHost: '',
        isWeb: false,
        platform: TargetPlatform.iOS,
      );
      final desktopHost = ApiConfig.resolveHost(
        overrideHost: '',
        isWeb: false,
        platform: TargetPlatform.macOS,
      );

      expect(iosHost, 'localhost');
      expect(desktopHost, 'localhost');
    });
  });

  group('ApiConfig.resolveWebSocketScheme', () {
    test('maps http to ws', () {
      expect(ApiConfig.resolveWebSocketScheme('http'), 'ws');
    });

    test('maps https to wss', () {
      expect(ApiConfig.resolveWebSocketScheme('https'), 'wss');
    });
  });
}
