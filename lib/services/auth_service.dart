import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Simulasi database user di memori
  final Map<String, AppUser> _usersByEmail = {};         // email -> user
  final Map<String, String> _passwordsByEmail = {};      // email -> password

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // ----- Register -----
  // return true jika sukses, false jika email sudah terpakai
  bool register(String email, String password, String name) {
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
    _currentUser = user;          // auto login setelah register
    notifyListeners();
    return true;
  }

  // ----- Login -----
  bool login(String email, String password) {
    final key = email.trim().toLowerCase();
    if (!_usersByEmail.containsKey(key)) return false;
    final ok = _passwordsByEmail[key] == password;
    if (!ok) return false;
    _currentUser = _usersByEmail[key];
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ----- Update Profile -----
  // kembalikan true jika berhasil, false kalau belum login
  bool updateProfile({required String name, String? phone, String? photoUrl}) {
    final u = _currentUser;
    if (u == null) return false;

    final updated = u.copyWith(
      name: name.trim().isEmpty ? u.name : name.trim(),
      phone: (phone?.trim().isEmpty ?? true) ? null : phone!.trim(),
      photoUrl: (photoUrl?.trim().isEmpty ?? true) ? null : photoUrl!.trim(),
    );

    _currentUser = updated;
    _usersByEmail[u.email] = updated; // simpan di "db" in-memory
    notifyListeners();
    return true;
  }
}
