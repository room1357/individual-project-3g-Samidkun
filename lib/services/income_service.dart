import 'package:flutter/foundation.dart';
import '../models/income.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class IncomeService extends ChangeNotifier {
  IncomeService._();
  static final IncomeService instance = IncomeService._();

 final StorageService _storage = FileStorageService();
  List<Income> _allIncomes = [];

  String? get _uid => AuthService.instance.currentUser?.id;

  List<Income> get incomes {
    final uid = _uid;
    if (uid == null) return const [];
    return _allIncomes.where((i) => i.ownerId == uid).toList(growable: false);
  }

  Future<void> loadInitialData() async {
    _allIncomes = await _storage.loadIncomes();
    notifyListeners();
  }

  void addIncome(Income i) {
    final uid = _uid;
    if (uid == null) return;
    final withOwner = (i.ownerId == uid) ? i : i.copyWith(ownerId: uid);
    _allIncomes.add(withOwner);
    _storage.saveIncomes(_allIncomes);
    notifyListeners();
  }

  void updateIncome(Income i) {
    final idx = _allIncomes.indexWhere((x) => x.id == i.id);
    if (idx != -1) {
      _allIncomes[idx] = i;
      _storage.saveIncomes(_allIncomes);
      notifyListeners();
    }
  }

  void deleteIncome(String id) {
    _allIncomes.removeWhere((x) => x.id == id);
    _storage.saveIncomes(_allIncomes);
    notifyListeners();
  }

  Income? getById(String id) {
    final uid = _uid;
    if (uid == null) return null;
    try {
      return _allIncomes.firstWhere((i) => i.id == id && i.ownerId == uid);
    } catch (_) {
      return null;
    }
  }

  // ---- ringkasan sederhana ----
  double get totalAll => incomes.fold(0.0, (s, i) => s + i.amount);

  Map<int, double> get totalPerMonth {
    final map = <int, double>{};
    for (final i in incomes) {
      map[i.date.month] = (map[i.date.month] ?? 0.0) + i.amount;
    }
    return map;
  }

  Map<int, double> get totalPerYear {
    final map = <int, double>{};
    for (final i in incomes) {
      map[i.date.year] = (map[i.date.year] ?? 0.0) + i.amount;
    }
    return map;
  }
}
