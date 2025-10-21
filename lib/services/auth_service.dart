import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  final Map<String, AppUser> _usersByEmail = {};
  final Map<String, String> _passwordsByEmail = {};

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<bool> register(String email, String password, String name) async {
    final key = email.trim().toLowerCase();
    if (key.isEmpty || password.trim().isEmpty || name.trim().isEmpty) return false;
    if (_usersByEmail.containsKey(key)) return false;

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: key,
      name: name.trim(),
      phone: null,
      photoUrl: null,
      createdAt: DateTime.now(),
    );

    _usersByEmail[key] = user;
    _passwordsByEmail[key] = password;
    _currentUser = user;
    
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    final key = email.trim().toLowerCase();
    if (!_usersByEmail.containsKey(key)) return false;
    final ok = _passwordsByEmail[key] == password;
    if (!ok) return false;
    
    _currentUser = _usersByEmail[key];
    
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path_${_currentUser!.id}');
    
    if (imagePath != null) {
      _currentUser = _currentUser!.copyWith(photoUrl: imagePath);
      _usersByEmail[key] = _currentUser!;
    }

    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // [DIUBAH] Fungsi updateProfile diperbaiki agar null-safe
  bool updateProfile({required String name, String? phone, String? photoUrl}) {
    final u = _currentUser;
    if (u == null) return false;

    // Logika baru yang lebih aman
    final String finalName = name.trim().isEmpty ? u.name : name.trim();
    final String? finalPhone = (phone?.trim().isEmpty ?? true) ? u.phone : phone!.trim();
    final String? finalPhotoUrl = (photoUrl?.trim().isEmpty ?? true) ? u.photoUrl : photoUrl!.trim();

    final updated = u.copyWith(
      name: finalName,
      phone: finalPhone,
      photoUrl: finalPhotoUrl,
    );

    _currentUser = updated;
    _usersByEmail[u.email] = updated;
    notifyListeners();
    return true;
  }

  bool changePassword(String newPassword) {
    if (_currentUser == null) return false;
    if (newPassword.trim().length < 6) return false;

    final email = _currentUser!.email;
    _passwordsByEmail[email] = newPassword.trim();
    debugPrint("Password untuk $email berhasil diubah (versi lokal).");
    return true;
  }
}