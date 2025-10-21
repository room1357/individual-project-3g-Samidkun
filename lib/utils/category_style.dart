// File: lib/utils/category_style.dart

import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/category.dart';

/// Peta string -> IconData yang kita dukung.
/// Ini adalah satu-satunya sumber ikon untuk kategori.
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

/// Fallback: ikon default jika tidak ada mapping.
const IconData kDefaultIcon = Icons.category;

/// Warna stabil dari string (berdasar hash).
Color _hashColor(String input) {
  final h = input.toLowerCase().hashCode;
  final hue = (h % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.45, 0.60).toColor();
}

/// Ambil IconData dari string key.
IconData _iconFromKey(String? rawKey) {
  if (rawKey == null || rawKey.trim().isEmpty) return kDefaultIcon;
  final key = rawKey.trim().toLowerCase();
  return kIconMap[key] ?? kDefaultIcon;
}

// ----- API yang dipakai screen -----

Color colorOf(String categoryName) {
  return _hashColor(categoryName);
}

IconData iconOf(String categoryName) {
  final CategoryModel? c =
      ExpenseService.instance.findCategoryByName(categoryName);
  if (c != null) {
    return _iconFromKey(c.iconKey);
  }
  return kDefaultIcon;
}

Color categoryColor(String name) => colorOf(name);
IconData categoryIcon(String name) => iconOf(name);

// [DIUBAH] Widget avatar sekarang lebih sederhana
Widget categoryAvatar(String categoryName, {double size = 40}) {
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

// --- TAMBAHKAN KODE WIDGET BARU INI DI BAWAH KODE SEBELUMNYA ---

class IconPickerDropdown extends StatelessWidget {
  // Nilai (key) ikon yang sedang dipilih, contoh: 'food'
  final String? selectedIconKey;
  
  // Fungsi yang akan dipanggil saat user memilih ikon baru
  final ValueChanged<String?> onChanged;

  const IconPickerDropdown({
    super.key,
    required this.selectedIconKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedIconKey,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Pilih Ikon',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // Membuat daftar item dropdown dari kIconMap
      items: kIconMap.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key, // Nilai yang disimpan adalah key-nya (String)
          child: Row(
            children: [
              Icon(entry.value), // Tampilkan ikon
              const SizedBox(width: 12),
              Text(entry.key), // Tampilkan nama key-nya
            ],
          ),
        );
      }).toList(),
    );
  }
}