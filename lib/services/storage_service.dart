import '../models/expense.dart';
import '../models/category.dart';

abstract class StorageService {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> v);
  Future<List<CategoryModel>> loadCategories();
  Future<void> saveCategories(List<CategoryModel> v);
}

class InMemoryStorageService implements StorageService {
  // Seed user demo
  static const demoUser = 'u-demo';

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
    // ... isi yang lain kalau perlu
  ];

  List<CategoryModel> _cats = <CategoryModel>[
    // Global categories
    CategoryModel(id: 'g-food', name: 'Makanan', ownerId: 'global'),
    CategoryModel(id: 'g-transport', name: 'Transportasi', ownerId: 'global'),
    CategoryModel(id: 'g-util', name: 'Utilitas', ownerId: 'global'),
    CategoryModel(id: 'g-fun', name: 'Hiburan', ownerId: 'global'),
    CategoryModel(id: 'g-edu', name: 'Pendidikan', ownerId: 'global'),
    // (opsional) kategori milik demoUser
    // CategoryModel(id: 'u1-custom', name: 'Kost', ownerId: demoUser),
  ];

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
}
