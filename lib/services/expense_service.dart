import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class ExpenseService extends ChangeNotifier {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  final StorageService _storage = InMemoryStorageService();

  List<Expense> _allExpenses = [];
  List<CategoryModel> _allCategories = [];

  String? get _uid => AuthService.instance.currentUser?.id;

  List<Expense> get expenses {
    final uid = _uid;
    if (uid == null) return const [];
    return _allExpenses.where((e) => e.ownerId == uid).toList(growable: false);
  }

  List<CategoryModel> get categories {
    final uid = _uid;
    if (uid == null) return const [];
    return _allCategories
        .where((c) => c.ownerId == 'global' || c.ownerId == uid)
        .toList(growable: false);
  }

  Future<void> loadInitialData() async {
    _allExpenses = await _storage.loadExpenses();
    _allCategories = await _storage.loadCategories();
    notifyListeners();
  }

  // ---------- Expense CRUD (Dikembalikan) ----------
  void addExpense(Expense e) {
    final uid = _uid;
    if (uid == null) return;
    final withOwner = (e.ownerId == uid) ? e : e.copyWith(ownerId: uid);
    _allExpenses.add(withOwner);
    _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }

  void updateExpense(Expense e) {
    final i = _allExpenses.indexWhere((x) => x.id == e.id);
    if (i != -1) {
      _allExpenses[i] = e;
      _storage.saveExpenses(_allExpenses);
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _allExpenses.removeWhere((x) => x.id == id);
    _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }

  Expense? getById(String id) {
    final uid = _uid;
    if (uid == null) return null;
    try {
      return _allExpenses.firstWhere((e) => e.id == id && e.ownerId == uid);
    } catch (_) {
      return null;
    }
  }

  // ---------- Category (Dikembalikan & Disesuaikan) ----------
  bool addCategory({required String name, String? iconKey}) {
    final uid = _uid;
    if (uid == null) return false;

    final n = name.trim();
    if (n.isEmpty) return false;

    final exists = _allCategories.any((c) =>
        (c.ownerId == 'global' || c.ownerId == uid) &&
        c.name.toLowerCase() == n.toLowerCase());
    if (exists) return false;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _allCategories.add(CategoryModel(
      id: id,
      ownerId: uid,
      name: n,
      iconKey: iconKey?.trim().isEmpty == true ? null : iconKey?.trim(),
      imageUrl: null, // imageUrl tidak lagi dipakai
    ));
    _storage.saveCategories(_allCategories);
    notifyListeners();
    return true;
  }

  bool deleteCategory(String id) {
    final uid = _uid;
    if (uid == null) return false;

    final cat = _allCategories.firstWhere(
      (c) => c.id == id && c.ownerId == uid,
      orElse: () => CategoryModel(id: '', name: '', ownerId: ''),
    );
    if (cat.id.isEmpty) return false;

    final inUse = _allExpenses.any(
      (e) => e.ownerId == uid && e.category.toLowerCase() == cat.name.toLowerCase(),
    );
    if (inUse) return false;

    _allCategories.removeWhere((c) => c.id == id && c.ownerId == uid);
    _storage.saveCategories(_allCategories);
    notifyListeners();
    return true;
  }

  CategoryModel? findCategoryByName(String name) {
    final uid = _uid;
    if (uid == null) return null;
    try {
      return _allCategories.firstWhere((c) =>
          (c.ownerId == 'global' || c.ownerId == uid) &&
          c.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  // ---------- Stats (Disederhanakan) ----------
  double get totalAll => expenses.fold(0.0, (s, e) => s + e.amount);

  Map<String, double> get totalPerCategory {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  Map<int, double> get totalPerMonth {
    final map = <int, double>{};
    for (final e in expenses) {
      map[e.date.month] = (map[e.date.month] ?? 0.0) + e.amount;
    }
    return map;
  }

  Map<int, double> get totalPerYear {
    final map = <int, double>{};
    for (final e in expenses) {
      map[e.date.year] = (map[e.date.year] ?? 0.0) + e.amount;
    }
    return map;
  }
}