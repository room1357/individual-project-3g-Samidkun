class AppUser {
  final String id;
  final String email;
  final String password;
  final String displayName;

  AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
  });

  AppUser copyWith({
    String? displayName,
    String? password,
  }) {
    return AppUser(
      id: id,
      email: email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
    );
  }
}
