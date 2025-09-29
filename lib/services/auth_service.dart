import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

/// In-memory auth sederhana untuk Proyek 2.
/// - Simpan user di memori (Map by email)
/// - Menyediakan register, login, logout, update profile
/// - Mengelola currentUser agar fitur lain (expense, kategori) bisa tahu ownerId
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Key: email (lowercase), Value: AppUser
  final Map<String, AppUser> _usersByEmail = {};

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  get currentUserId => null;

  /// Register user baru. return true bila sukses, false jika email sudah ada / input kosong.
  bool register({
    required String email,
    required String password,
    required String name,
  }) {
    final key = email.trim().toLowerCase();
    if (key.isEmpty || password.trim().isEmpty || name.trim().isEmpty) return false;
    if (_usersByEmail.containsKey(key)) return false; // email sudah terdaftar

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: key,
      password: password,
      displayName: name.trim(),
    );

    _usersByEmail[key] = user;
    _currentUser = user; // auto-login setelah register (opsional)
    notifyListeners();
    return true;
  }

  /// Login berdasarkan email + password. return true bila sukses.
  bool login({
    required String email,
    required String password,
  }) {
    final key = email.trim().toLowerCase();
    final u = _usersByEmail[key];
    if (u == null) return false;
    if (u.password != password) return false;

    _currentUser = u;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Update profil user yang sedang login.
  /// Kosongkan parameter jika tidak ingin diubah.
  void updateProfile({String? displayName, String? newPassword}) {
    final u = _currentUser;
    if (u == null) return;

    final updated = u.copyWith(
      displayName: (displayName == null || displayName.trim().isEmpty)
          ? u.displayName
          : displayName.trim(),
      password: (newPassword == null || newPassword.isEmpty)
          ? u.password
          : newPassword,
    );

    _currentUser = updated;
    _usersByEmail[u.email.toLowerCase()] = updated;
    notifyListeners();
  }
}
