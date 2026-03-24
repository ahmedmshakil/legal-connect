import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_v1/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test(
      'parses nested profilePicture payloads from backend user-info response',
      () {
        final user = UserModel.fromJson({
          'firstName': 'Demo',
          'lastName': 'User',
          'email': 'demo.user@legalconnect.local',
          'role': 'USER',
          'emailVerified': true,
          'profilePicture': {
            'fullPictureUrl': 'https://cdn.example.com/full.png',
            'thumbnailPictureUrl': 'https://cdn.example.com/thumb.png',
          },
        });

        expect(user.profilePictureUrl, 'https://cdn.example.com/full.png');
        expect(
          user.profilePictureThumbnailUrl,
          'https://cdn.example.com/thumb.png',
        );
      },
    );
  });

  group('UserModel.withFallback', () {
    test('preserves cached id when user-info payload omits it', () {
      final cachedUser = UserModel(
        id: 'user-123',
        email: 'demo.user@legalconnect.local',
        role: 'USER',
      );
      final fetchedUser = UserModel.fromJson({
        'firstName': 'Demo',
        'lastName': 'User',
        'email': 'demo.user@legalconnect.local',
        'emailVerified': true,
      });

      final mergedUser = fetchedUser.withFallback(cachedUser);

      expect(mergedUser.id, 'user-123');
      expect(mergedUser.role, 'USER');
      expect(mergedUser.firstName, 'Demo');
      expect(mergedUser.emailVerified, isTrue);
    });
  });
}
