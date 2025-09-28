import 'dart:async';
import '../models/expense.dart';
import '../models/category.dart';

/// Abstraksi penyimpanan. Sekarang in-memory; nanti bisa diganti ke file/SQLite.
abstract class StorageService {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> items);

  Future<List<CategoryModel>> loadCategories();
  Future<void> saveCategories(List<CategoryModel> items);
}

/// Implementasi sementara: in-memory (dummy persist).
class InMemoryStorageService implements StorageService {
  List<Expense> _expenses = [];
  List<CategoryModel> _categories = [];

  @override
  Future<List<Expense>> loadExpenses() async {
    // seed data awal kalau kosong
    if (_expenses.isEmpty) {
      _expenses = [
        Expense(id: '1', title: 'Belanja Bulanan', amount: 150000, category: 'Makanan', date: DateTime(2024,9,15), description: 'Supermarket'),
        Expense(id: '2', title: 'Bensin Motor', amount: 50000, category: 'Transportasi', date: DateTime(2024,9,14), description: 'Pertalite'),
        Expense(id: '3', title: 'Kopi di Cafe', amount: 25000, category: 'Makanan', date: DateTime(2024,9,14), description: 'Ngopi'),
        Expense(id: '4', title: 'Tagihan Internet', amount: 300000, category: 'Utilitas', date: DateTime(2024,9,13), description: 'Bulanan'),
      ];
    }
    return Future.value(List.of(_expenses));
  }

  @override
  Future<void> saveExpenses(List<Expense> items) async {
    _expenses = List.of(items);
  }

  @override
  Future<List<CategoryModel>> loadCategories() async {
    if (_categories.isEmpty) {
      _categories = [
        CategoryModel(id: 'c1', name: 'Makanan'),
        CategoryModel(id: 'c2', name: 'Transportasi'),
        CategoryModel(id: 'c3', name: 'Utilitas'),
        CategoryModel(id: 'c4', name: 'Hiburan'),
        CategoryModel(id: 'c5', name: 'Pendidikan'),
      ];
    }
    return Future.value(List.of(_categories));
  }

  @override
  Future<void> saveCategories(List<CategoryModel> items) async {
    _categories = List.of(items);
  }
}
