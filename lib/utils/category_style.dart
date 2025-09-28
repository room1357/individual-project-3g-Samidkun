import 'package:flutter/material.dart';

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'makanan':        return Icons.restaurant;
    case 'transportasi':   return Icons.directions_car;
    case 'utilitas':       return Icons.home;
    case 'hiburan':        return Icons.movie;
    case 'pendidikan':     return Icons.school;
    default:               return Icons.category; // fallback utk kategori baru/aneh
  }
}

Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'makanan':        return Colors.orange;
    case 'transportasi':   return Colors.green;
    case 'utilitas':       return Colors.purple;
    case 'hiburan':        return Colors.pink;
    case 'pendidikan':     return Colors.blue;
    default:               return Colors.grey;   // fallback aman
  }
}
