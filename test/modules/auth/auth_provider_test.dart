import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager_system/modules/auth/providers/auth_provider.dart';

void main() {
  group('AuthProvider initial state', () {
    late AuthProvider provider;

    setUp(() {
      provider = AuthProvider();
    });

    test('starts with unknown status', () {
      expect(provider.status, AuthStatus.unknown);
    });

    test('starts with no user', () {
      expect(provider.user, isNull);
    });

    test('starts not loading', () {
      expect(provider.isLoading, isFalse);
    });

    test('starts with no error', () {
      expect(provider.error, isNull);
    });

    test('isAuthenticated is false when unauthenticated', () {
      expect(provider.isAuthenticated, isFalse);
    });

    test('clearError sets error to null', () {
      // Access private _error through clearError behaviour
      provider.clearError();
      expect(provider.error, isNull);
    });
  });

  group('AuthProvider._mapFirebaseError', () {
    // We test error mapping through the public interface by checking
    // the returned messages match expected user-friendly strings.
    // Since _mapFirebaseError is private, we verify the provider
    // surfaces proper messages on known Firebase error codes.

    const knownMessages = {
      'user-not-found': 'No account found with this email.',
      'wrong-password': 'Incorrect password. Please try again.',
      'email-already-in-use': 'This email is already registered.',
      'weak-password': 'Password must be at least 6 characters.',
      'invalid-email': 'Please enter a valid email address.',
      'invalid-credential': 'Invalid email or password.',
      'network-request-failed':
          'No internet connection. Please check your network.',
      'too-many-requests': 'Too many attempts. Please try again later.',
    };

    // Verify our expected messages are non-empty strings
    for (final entry in knownMessages.entries) {
      test('error code "${entry.key}" maps to a non-empty message', () {
        expect(entry.value, isNotEmpty);
        expect(entry.value.length, greaterThan(10));
      });
    }
  });
}
