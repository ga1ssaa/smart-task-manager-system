import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager_system/modules/auth/models/user_model.dart';

void main() {
  group('UserModel', () {
    final now = DateTime(2025, 1, 15);

    final sampleMap = {
      'uid': 'abc123',
      'name': 'John Doe',
      'email': 'john@example.com',
      'photoUrl': null,
      'bio': 'Flutter developer',
      'phone': '+7 700 000 0000',
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': null,
    };

    test('fromMap creates model correctly', () {
      final user = UserModel.fromMap(sampleMap);

      expect(user.uid, 'abc123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.bio, 'Flutter developer');
      expect(user.phone, '+7 700 000 0000');
      expect(user.photoUrl, isNull);
      expect(
        user.createdAt.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
    });

    test('toMap serializes model correctly', () {
      final user = UserModel(
        uid: 'abc123',
        name: 'John Doe',
        email: 'john@example.com',
        bio: 'Flutter developer',
        createdAt: now,
      );
      final map = user.toMap();

      expect(map['uid'], 'abc123');
      expect(map['name'], 'John Doe');
      expect(map['email'], 'john@example.com');
      expect(map['createdAt'], now.millisecondsSinceEpoch);
    });

    test('copyWith updates only specified fields', () {
      final user = UserModel(
        uid: 'abc123',
        name: 'John',
        email: 'john@example.com',
        createdAt: now,
      );

      final updated = user.copyWith(name: 'Jane', bio: 'Designer');

      expect(updated.name, 'Jane');
      expect(updated.bio, 'Designer');
      expect(updated.uid, 'abc123'); // unchanged
      expect(updated.email, 'john@example.com'); // unchanged
    });

    test('equality is based on uid', () {
      final user1 = UserModel(
        uid: 'same-uid',
        name: 'Alice',
        email: 'alice@example.com',
        createdAt: now,
      );
      final user2 = UserModel(
        uid: 'same-uid',
        name: 'Bob',
        email: 'bob@example.com',
        createdAt: now,
      );
      final user3 = UserModel(
        uid: 'different-uid',
        name: 'Alice',
        email: 'alice@example.com',
        createdAt: now,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('fromMap handles missing optional fields gracefully', () {
      final minimalMap = {
        'uid': 'xyz',
        'name': 'Min',
        'email': 'min@example.com',
        'createdAt': now.millisecondsSinceEpoch,
      };

      final user = UserModel.fromMap(minimalMap);
      expect(user.photoUrl, isNull);
      expect(user.bio, isNull);
      expect(user.phone, isNull);
    });

    test('roundtrip fromMap → toMap preserves data', () {
      final original = UserModel(
        uid: 'rt1',
        name: 'Round Trip',
        email: 'rt@test.com',
        bio: 'A bio',
        phone: '+1 000',
        createdAt: now,
      );

      final restored = UserModel.fromMap(original.toMap());

      expect(restored.uid, original.uid);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.bio, original.bio);
      expect(restored.phone, original.phone);
    });
  });
}
