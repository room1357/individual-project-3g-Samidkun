class CategoryModel {
  final String id;
  final String name;
  final String ownerId; // 'global' atau userId

  CategoryModel({
    required this.id,
    required this.name,
    required this.ownerId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: j['id'] as String,
        name: j['name'] as String,
        ownerId: j['ownerId'] as String? ?? 'global',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerId': ownerId,
      };
}
