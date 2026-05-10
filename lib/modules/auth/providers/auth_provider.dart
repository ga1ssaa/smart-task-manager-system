import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  AuthStatus _status = AuthStatus.unknown;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkSession() async {
    _setLoading(true);
    try {
      final cached = await _service.loadCachedSession();
      if (cached != null) {
        _user = cached;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _service.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _mapError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _service.signUp(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _mapError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _service.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? phone,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    _error = null;
    try {
      _user = await _service.updateProfile(
        uid: _user!.uid,
        name: name,
        bio: bio,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    if (_user == null) return false;
    _setLoading(true);
    _error = null;
    try {
      final url = await _service.uploadAvatar(
        uid: _user!.uid,
        imageFile: imageFile,
      );
      _user = _user!.copyWith(photoUrl: url);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update photo. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _service.sendPasswordReset(email);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapError(String raw) {
    if (raw.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (raw.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (raw.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (raw.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (raw.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    return 'Something went wrong. Please try again.';
  }
}
