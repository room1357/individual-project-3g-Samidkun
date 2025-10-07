import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/category.dart';

/// Peta string -> IconData yang kita dukung.
/// User mengisi `iconKey` salah satu dari key ini (case-insensitive).
const Map<String, IconData> kIconMap = {
  'food': Icons.restaurant,
  'makanan': Icons.restaurant,
  'coffee': Icons.local_cafe,
  'cafe': Icons.local_cafe,
  'transport': Icons.directions_bus,
  'bus': Icons.directions_bus,
  'motor': Icons.two_wheeler,
  'shopping': Icons.shopping_bag,
  'belanja': Icons.shopping_bag,
  'home': Icons.home,
  'house': Icons.home,
  'internet': Icons.wifi,
  'wifi': Icons.wifi,
  'game': Icons.videogame_asset,
  'entertainment': Icons.movie,
  'movie': Icons.movie,
  'phone': Icons.phone_android,
  'health': Icons.health_and_safety,
  'education': Icons.school,
  'school': Icons.school,
  'book': Icons.menu_book,
  'fuel': Icons.local_gas_station,
  'gift': Icons.card_giftcard,
  'other': Icons.category,
  'lainnya': Icons.category,
};

/// Fallback: ikon default jika tidak ada mapping / user tidak mengisi.
const IconData kDefaultIcon = Icons.category;

/// Warna stabil dari string (berdasar hash), biar tiap kategori punya warna tetap.
Color _hashColor(String input) {
  final h = input.toLowerCase().hashCode;
  // variasikan hue saja supaya tetap lembut
  final hue = (h % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.45, 0.60).toColor();
}

/// Ambil IconData dari string key user.
IconData _iconFromKey(String? rawKey) {
  if (rawKey == null || rawKey.trim().isEmpty) return kDefaultIcon;
  final key = rawKey.trim().toLowerCase();
  return kIconMap[key] ?? kDefaultIcon;
}

/// ----- API yang dipakai screen -----
/// color/icon berdasarkan NAMA KATEGORI.
/// Jika kategori punya imageUrl, warna tetap dipakai (ikon di ListTile akan
/// otomatis menunjukkan gambar di UI kalau kamu edit ListTile-nya).

Color colorOf(String categoryName) {
  return _hashColor(categoryName);
}

IconData iconOf(String categoryName) {
  // cek apakah user menaruh key di kategori
  final CategoryModel? c =
      ExpenseService.instance.findCategoryByName(categoryName);
  if (c != null) {
    return _iconFromKey(c.iconKey);
  }
  return kDefaultIcon;
}

/// --- Backward compatibility (agar error lama hilang) ---
Color categoryColor(String name) => colorOf(name);
IconData categoryIcon(String name) => iconOf(name);
/// Widget avatar dinamis kategori: jika ada imageUrl -> tampil gambar
/// jika tidak -> tampil ikon sesuai iconKey, jika tetap kosong -> ikon default
Widget categoryAvatar(String categoryName, {double size = 40}) {
  final cat = ExpenseService.instance.findCategoryByName(categoryName);

  if (cat != null && cat.imageUrl != null && cat.imageUrl!.isNotEmpty) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(cat.imageUrl!),
      onBackgroundImageError: (_, __) {},
    );
  }

  return CircleAvatar(
    radius: size / 2,
    backgroundColor: categoryColor(categoryName),
    child: Icon(
      categoryIcon(categoryName),
      color: Colors.white,
      size: size * 0.5,
    ),
  );
}

