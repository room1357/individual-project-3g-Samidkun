import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';

class ExpenseService extends ChangeNotifier {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  final StorageService _storage = InMemoryStorageService();

  List<Expense> _expenses = [];
  List<CategoryModel> _categories = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  Future<void> loadInitialData() async {
    _expenses = await _storage.loadExpenses();
    _categories = await _storage.loadCategories();
    notifyListeners();
  }

  // ---------- Expense CRUD ----------
  void addExpense(Expense e) {
    _expenses.add(e);
    _storage.saveExpenses(_expenses);
    notifyListeners();
  }

  void updateExpense(Expense e) {
    final i = _expenses.indexWhere((x) => x.id == e.id);
    if (i != -1) {
      _expenses[i] = e;
      _storage.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((x) => x.id == id);
    _storage.saveExpenses(_expenses);
    notifyListeners();
  }

  /// Ambil data berdasarkan id. Mengembalikan null jika tidak ditemukan.
  Expense? getById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------- Category management ----------
  bool addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return false;
    if (_categories.any((c) => c.name.toLowerCase() == n.toLowerCase())) return false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _categories.add(CategoryModel(id: id, name: n));
    _storage.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  bool renameCategory(String id, String newName) {
    final n = newName.trim();
    if (n.isEmpty) return false;
    if (_categories.any((c) => c.name.toLowerCase() == n.toLowerCase())) return false;
    final idx = _categories.indexWhere((c) => c.id == id);
    if (idx == -1) return false;

    // update kategori
    final oldName = _categories[idx].name;
    _categories[idx] = CategoryModel(id: id, name: n);

    // migrasi semua expense yang pakai kategori lama
    for (int i = 0; i < _expenses.length; i++) {
      if (_expenses[i].category == oldName) {
        _expenses[i] = Expense(
          id: _expenses[i].id,
          title: _expenses[i].title,
          amount: _expenses[i].amount,
          category: n,
          date: _expenses[i].date,
          description: _expenses[i].description,
        );
      }
    }

    _storage.saveCategories(_categories);
    _storage.saveExpenses(_expenses);
    notifyListeners();
    return true;
  }

  bool deleteCategory(String id) {
    final cat = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryModel(id: '', name: ''),
    );
    if (cat.id.isEmpty) return false;
    final inUse = _expenses.any((e) => e.category == cat.name);
    if (inUse) return false;
    _categories.removeWhere((c) => c.id == id);
    _storage.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  // ---------- Stats ----------
  double get totalAll => _expenses.fold(0.0, (s, e) => s + e.amount);

  Map<String, double> get totalPerCategory {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  Map<int, double> get totalPerMonth {
    final map = <int, double>{};
    for (final e in _expenses) {
      map[e.date.month] = (map[e.date.month] ?? 0.0) + e.amount;
    }
    return map;
  }
}
