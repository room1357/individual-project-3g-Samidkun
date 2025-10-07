class CategoryModel {
  final String id;
  final String ownerId;          // pemilik kategori (user id) atau "global"
  final String name;

  /// Ikon material opsional – disimpan sebagai string key (mis. "shopping", "food")
  final String? iconKey;

  /// Gambar opsional – jika ada, dipakai sebagai gambar kategori
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.iconKey,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: j['id'] as String,
        ownerId: j['ownerId'] as String? ?? '',
        name: j['name'] as String,
        iconKey: j['iconKey'] as String?,
        imageUrl: j['imageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'iconKey': iconKey,
        'imageUrl': imageUrl,
      };

  CategoryModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? iconKey,
    String? imageUrl,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
