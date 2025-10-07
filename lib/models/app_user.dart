class AppUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  AppUser copyWith({
    String? name,
    String? phone,
    String? photoUrl,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        email: j['email'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String?,
        photoUrl: j['photoUrl'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
