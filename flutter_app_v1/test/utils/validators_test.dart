import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_v1/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts demo local-domain email addresses', () {
      expect(Validators.email('demo.user1@legalconnect.local'), isNull);
    });

    test('rejects malformed email addresses', () {
      expect(
        Validators.email('demo.user1legalconnect.local'),
        'Please enter a valid email',
      );
    });
  });
}
