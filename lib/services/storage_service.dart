// lib/services/storage_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../models/income.dart';

abstract class StorageService {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> v);

  Future<List<CategoryModel>> loadCategories();
  Future<void> saveCategories(List<CategoryModel> v);

  // Income
  Future<List<Income>> loadIncomes();
  Future<void> saveIncomes(List<Income> v);
}

/// ===================================================================
///  PERSISTEN: SIMPAN DATA KE FILE JSON DI FOLDER DOKUMEN APLIKASI
///  (Android/iOS OK; kalau target Web, ini tidak didukung)
/// ===================================================================
class FileStorageService implements StorageService {
  // Nama file
  static const _fExpenses   = 'expenses.json';
  static const _fCategories = 'categories.json';
  static const _fIncomes    = 'incomes.json';

  // Seed user demo (biar ada data awal saat file belum dibuat)
  static const demoUser = 'u-demo';

  Future<File> _file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }

  Future<void> _writeJson(File f, Object data) async {
    final pretty = const JsonEncoder.withIndent('  ').convert(data);
    await f.writeAsString(pretty, flush: true);
  }

  // ---------------- Expenses ----------------
  @override
  Future<List<Expense>> loadExpenses() async {
    final f = await _file(_fExpenses);
    if (!await f.exists()) {
      // Seed awal jika file belum ada
      final seed = <Expense>[
        Expense(
          id: '1',
          ownerId: demoUser,
          title: 'Belanja Bulanan',
          amount: 150000,
          category: 'Makanan',
          date: DateTime(2024, 9, 15),
          description: 'Belanja kebutuhan bulanan',
        ),
        Expense(
          id: '2',
          ownerId: demoUser,
          title: 'Bensin Motor',
          amount: 50000,
          category: 'Transportasi',
          date: DateTime(2024, 9, 14),
          description: 'Isi bensin',
        ),
      ];
      await saveExpenses(seed);
      return seed;
    }
    try {
      final txt = await f.readAsString();
      if (txt.trim().isEmpty) return [];
      final data = jsonDecode(txt) as List;
      return data
          .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      // Jika file korup, reset
      await _writeJson(f, []);
      return [];
    }
  }

  @override
  Future<void> saveExpenses(List<Expense> v) async {
    final f = await _file(_fExpenses);
    await _writeJson(f, v.map((e) => e.toJson()).toList());
  }

  // ---------------- Categories ----------------
  @override
  Future<List<CategoryModel>> loadCategories() async {
    final f = await _file(_fCategories);
    if (!await f.exists()) {
      final seed = <CategoryModel>[
        CategoryModel(id: 'g-food',      name: 'Makanan',      ownerId: 'global'),
        CategoryModel(id: 'g-transport', name: 'Transportasi', ownerId: 'global'),
        CategoryModel(id: 'g-util',      name: 'Utilitas',     ownerId: 'global'),
        CategoryModel(id: 'g-fun',       name: 'Hiburan',      ownerId: 'global'),
        CategoryModel(id: 'g-edu',       name: 'Pendidikan',   ownerId: 'global'),
      ];
      await saveCategories(seed);
      return seed;
    }
    try {
      final txt = await f.readAsString();
      if (txt.trim().isEmpty) return [];
      final data = jsonDecode(txt) as List;
      // Pastikan CategoryModel punya fromJson; kalau tidak, buat manual mapping sendiri.
      return data
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      await _writeJson(f, []);
      return [];
    }
  }

  @override
  Future<void> saveCategories(List<CategoryModel> v) async {
    final f = await _file(_fCategories);
    // Pastikan CategoryModel punya toJson; kalau belum, tambahkan di modelnya.
    await _writeJson(f, v.map((e) => e.toJson()).toList());
  }

  // ---------------- Incomes ----------------
  @override
  Future<List<Income>> loadIncomes() async {
    final f = await _file(_fIncomes);
    if (!await f.exists()) {
      await saveIncomes(const []);
      return const [];
    }
    try {
      final txt = await f.readAsString();
      if (txt.trim().isEmpty) return [];
      final data = jsonDecode(txt) as List;
      return data
          .map((e) => Income.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      await _writeJson(f, []);
      return [];
    }
  }

  @override
  Future<void> saveIncomes(List<Income> v) async {
    final f = await _file(_fIncomes);
    await _writeJson(f, v.map((e) => e.toJson()).toList());
  }
}

/// ===================================================================
///  IN-MEMORY: VERSI LAMA (UNTUK TEST CEPAT / NON-PERSISTEN)
/// ===================================================================
class InMemoryStorageService implements StorageService {
  // Seed user demo
  static const demoUser = 'u-demo';

  // ---------- Expenses ----------
  List<Expense> _ex = <Expense>[
    Expense(
      id: '1',
      ownerId: demoUser,
      title: 'Belanja Bulanan',
      amount: 150000,
      category: 'Makanan',
      date: DateTime(2024, 9, 15),
      description: 'Belanja kebutuhan bulanan',
    ),
    Expense(
      id: '2',
      ownerId: demoUser,
      title: 'Bensin Motor',
      amount: 50000,
      category: 'Transportasi',
      date: DateTime(2024, 9, 14),
      description: 'Isi bensin',
    ),
  ];

  // ---------- Categories ----------
  List<CategoryModel> _cats = <CategoryModel>[
    CategoryModel(id: 'g-food',      name: 'Makanan',      ownerId: 'global'),
    CategoryModel(id: 'g-transport', name: 'Transportasi', ownerId: 'global'),
    CategoryModel(id: 'g-util',      name: 'Utilitas',     ownerId: 'global'),
    CategoryModel(id: 'g-fun',       name: 'Hiburan',      ownerId: 'global'),
    CategoryModel(id: 'g-edu',       name: 'Pendidikan',   ownerId: 'global'),
  ];

  // ---------- Incomes ----------
  List<Income> _inc = <Income>[
    Income(
      id: 'i1',
      ownerId: demoUser,
      title: 'Gaji',
      amount: 3500000,
      date: DateTime(2024, 9, 1),
      description: 'Gaji bulanan',
    ),
    Income(
      id: 'i2',
      ownerId: demoUser,
      title: 'Bonus',
      amount: 250000,
      date: DateTime(2024, 9, 10),
      description: 'Bonus project',
    ),
  ];

  // ===== Implementasi interface =====
  @override
  Future<List<Expense>> loadExpenses() async => List.of(_ex);

  @override
  Future<void> saveExpenses(List<Expense> v) async {
    _ex = List.of(v);
  }

  @override
  Future<List<CategoryModel>> loadCategories() async => List.of(_cats);

  @override
  Future<void> saveCategories(List<CategoryModel> v) async {
    _cats = List.of(v);
  }

  // Income
  @override
  Future<List<Income>> loadIncomes() async => List.of(_inc);

  @override
  Future<void> saveIncomes(List<Income> v) async {
    _inc = List.of(v);
  }
}
