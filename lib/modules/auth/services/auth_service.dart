import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

// Local auth — no Firebase required.
// Swap uploadAvatar to use Firebase Storage when firebase_storage is added.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _usersKey = 'auth_users_db';
  static const String _sessionKey = 'auth_session';
  static const String _onboardingKey = 'auth_onboarding_done';

  // ─── Auth Operations ────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadAllUsers(prefs);

    final normalizedEmail = email.trim().toLowerCase();
    if (users.any((u) => u['email'] == normalizedEmail)) {
      throw const _AuthException('email-already-in-use');
    }

    final uid = _generateUid();
    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: normalizedEmail,
      createdAt: DateTime.now(),
    );

    users.add({...user.toMap(), '_password': password});
    await _saveAllUsers(prefs, users);
    await _cacheSession(prefs, user);
    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadAllUsers(prefs);
    final normalizedEmail = email.trim().toLowerCase();

    final matched = users.where((u) => u['email'] == normalizedEmail).toList();
    if (matched.isEmpty) throw const _AuthException('user-not-found');

    final userData = matched.firstWhere(
      (u) => u['_password'] == password,
      orElse: () => throw const _AuthException('wrong-password'),
    );

    final user = UserModel.fromMap(userData);
    await _cacheSession(prefs, user);
    return user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? bio,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadAllUsers(prefs);

    final index = users.indexWhere((u) => u['uid'] == uid);
    if (index == -1) throw const _AuthException('user-not-found');

    if (name != null && name.trim().isNotEmpty) {
      users[index]['name'] = name.trim();
    }
    if (bio != null) users[index]['bio'] = bio.trim();
    if (phone != null) users[index]['phone'] = phone.trim();
    users[index]['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

    await _saveAllUsers(prefs, users);
    final updated = UserModel.fromMap(users[index]);
    await _cacheSession(prefs, updated);
    return updated;
  }

  // Stores local file path as photoUrl.
  // Replace body with Firebase Storage upload when firebase is configured.
  Future<String> uploadAvatar({
    required String uid,
    required File imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadAllUsers(prefs);

    final index = users.indexWhere((u) => u['uid'] == uid);
    if (index != -1) {
      users[index]['photoUrl'] = imageFile.path;
      await _saveAllUsers(prefs, users);

      final cached = await loadCachedSession();
      if (cached != null) {
        await _cacheSession(prefs, cached.copyWith(photoUrl: imageFile.path));
      }
    }
    return imageFile.path;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // ─── Session ─────────────────────────────────────────────────────────────────

  Future<UserModel?> loadCachedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_sessionKey);
    if (json == null) return null;
    try {
      return UserModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  // ─── Onboarding ──────────────────────────────────────────────────────────────

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _loadAllUsers(
      SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAllUsers(
    SharedPreferences prefs,
    List<Map<String, dynamic>> users,
  ) async {
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> _cacheSession(SharedPreferences prefs, UserModel user) async {
    await prefs.setString(_sessionKey, jsonEncode(user.toMap()));
  }

  String _generateUid() {
    final rng = Random.secure();
    return List.generate(20, (_) => rng.nextInt(36).toRadixString(36)).join();
  }
}

class _AuthException implements Exception {
  final String code;
  const _AuthException(this.code);

  @override
  String toString() => 'AuthException($code)';
}
