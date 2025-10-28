// lib/services/user_directory_service.dart

class UserDirectoryService {
  UserDirectoryService._();
  static final instance = UserDirectoryService._();

  // internal store (private)
  final List<_UserLite> _users = <_UserLite>[];

  // --- helper sanitasi username ---
  String _sanitize(String raw) =>
      raw.trim().toLowerCase().replaceAll('@', '');


  /// Cari user berdasarkan username (tanpa @, case-insensitive).
  /// Return tipe publik [DirectoryUser] agar bisa dipakai file mana saja.
  DirectoryUser? findByUsername(String username) {
    final key = _sanitize(username);
    try {
      final u = _users.firstWhere((e) => e.username == key);
      return DirectoryUser.fromLite(u);
    } catch (_) {
      return null;
    }
  }

  /// Cari user berdasarkan ID.
  DirectoryUser? findById(String id) {
    try {
      final u = _users.firstWhere((e) => e.id == id);
      return DirectoryUser.fromLite(u);
    } catch (_) {
      return null;
    }
  }

  /// Tambah/update entri direktori (dipanggil saat register/login).
  void upsert({
    required String id,
    required String username,
    required String name,
    required String email,
  }) {
    final key = _sanitize(username);
    final i = _users.indexWhere((x) => x.id == id);
    final entry = _UserLite(id: id, username: key, name: name, email: email);
    if (i == -1) {
      _users.add(entry);
    } else {
      _users[i] = entry;
    }
  }
}

/// Tipe PUBLIK yang aman dipakai di mana saja.
class DirectoryUser {
  final String id;
  final String username;
  final String name;
  final String email;

  const DirectoryUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
  });

  factory DirectoryUser.fromLite(_UserLite u) => DirectoryUser(
        id: u.id,
        username: u.username,
        name: u.name,
        email: u.email,
      );
}

// Tipe internal (private untuk file ini)
class _UserLite {
  final String id;
  final String username;
  final String name;
  final String email;
  const _UserLite({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
  });
}
