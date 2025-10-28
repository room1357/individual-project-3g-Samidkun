import 'user_directory_service.dart'; // <-- TAMBAHKAN INI
import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';
import 'auth_service.dart';


class ExpenseService extends ChangeNotifier {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  // PAKAI penyimpanan persisten (FileStorageService)
  final StorageService _storage = FileStorageService();

  List<Expense> _allExpenses = [];
  List<CategoryModel> _allCategories = [];

  String? get _uid => AuthService.instance.currentUser?.id;

  // ---------- Data Load ----------
  Future<void> loadInitialData() async {
    _allExpenses = await _storage.loadExpenses();
    _allCategories = await _storage.loadCategories();
    notifyListeners();
  }

  // ---------- Getters: Expense ----------
  /// Expense milik saya (owner == saya)
  List<Expense> get expenses {
    final uid = _uid;
    if (uid == null) return const [];
    return _allExpenses.where((e) => e.ownerId == uid).toList(growable: false);
  }

  /// Expense milik user lain yang dishare ke saya
  List<Expense> get sharedToMe {
    final uid = _uid;
    if (uid == null) return const [];
    return _allExpenses
        .where((e) => e.ownerId != uid && e.sharedWith.contains(uid))
        .toList(growable: false);
  }

  /// Semua expense yang terlihat oleh saya (milik saya + dishare ke saya)
  List<Expense> get visibleExpenses {
    final map = <String, Expense>{};
    for (final e in expenses) map[e.id] = e;
    for (final e in sharedToMe) map[e.id] = e;
    return map.values.toList(growable: false);
  }

  // ---------- Getters: Category ----------
  List<CategoryModel> get categories {
    final uid = _uid;
    if (uid == null) return const [];
    return _allCategories
        .where((c) => c.ownerId == 'global' || c.ownerId == uid)
        .toList(growable: false);
  }

  // ---------- CRUD Expense ----------
  void addExpense(Expense e) {
    final uid = _uid;
    if (uid == null) return;
    final withOwner = (e.ownerId == uid) ? e : e.copyWith(ownerId: uid);
    _allExpenses.add(withOwner);
    _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }

  // --- SHARE (read-only) semua expense saya ke user lain (by username) ---
Future<int> shareAllToUsername(String username) async {
  final uid = _uid;
  if (uid == null) return 0;

  // cari user tujuan di "direktori" (username → id)
  final target = UserDirectoryService.instance.findByUsername(username);
  if (target == null) return 0;            // username tidak ditemukan
  if (target.id == uid) return 0;          // jangan share ke diri sendiri

  int changed = 0;
  for (var i = 0; i < _allExpenses.length; i++) {
    final e = _allExpenses[i];
    if (e.ownerId != uid) continue;        // hanya milik saya

    if (!e.sharedWith.contains(target.id)) {
      _allExpenses[i] = e.copyWith(
        sharedWith: [...e.sharedWith, target.id],
      );
      changed++;
    }
  }

  if (changed > 0) {
    await _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }
  return changed;
}

// --- Hentikan share semua expense saya ke user tsb (opsional) ---
Future<int> unshareAllFromUsername(String username) async {
  final uid = _uid;
  if (uid == null) return 0;

  final target = UserDirectoryService.instance.findByUsername(username);
  if (target == null) return 0;

  int changed = 0;
  for (var i = 0; i < _allExpenses.length; i++) {
    final e = _allExpenses[i];
    if (e.ownerId != uid) continue;

    if (e.sharedWith.contains(target.id)) {
      _allExpenses[i] = e.copyWith(
        sharedWith: e.sharedWith.where((x) => x != target.id).toList(),
      );
      changed++;
    }
  }

  if (changed > 0) {
    await _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }
  return changed;
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

  // ---------- CRUD Category ----------
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
      imageUrl: null,
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

  // ---------- Stats (lama: total tagihan milik saya saja) ----------
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

  // ---------- Stats (baru: berdasarkan porsi SAYA dari semua expense yang terlihat) ----------
  double get myTotalAll {
    final uid = _uid;
    if (uid == null) return 0;
    return visibleExpenses.fold(0.0, (s, e) => s + e.shareFor(uid));
  }

  Map<String, double> get myTotalPerCategory {
    final uid = _uid;
    if (uid == null) return const {};
    final map = <String, double>{};
    for (final e in visibleExpenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.shareFor(uid);
    }
    return map;
  }

  Map<int, double> get myTotalPerMonth {
    final uid = _uid;
    if (uid == null) return const {};
    final map = <int, double>{};
    for (final e in visibleExpenses) {
      map[e.date.month] = (map[e.date.month] ?? 0.0) + e.shareFor(uid);
    }
    return map;
  }

  Map<int, double> get myTotalPerYear {
    final uid = _uid;
    if (uid == null) return const {};
    final map = <int, double>{};
    for (final e in visibleExpenses) {
      map[e.date.year] = (map[e.date.year] ?? 0.0) + e.shareFor(uid);
    }
    return map;
  }
}
