import '../models/expense.dart';

/// Latihan 5 — Contoh looping, pencarian, dan filtering list
class LoopingExamples {
  // ------------------------------
  // 1. Menghitung Total
  // ------------------------------

  /// Cara 1: for (index)
  static double totalForIndex(List<Expense> list) {
    double total = 0;
    for (int i = 0; i < list.length; i++) {
      total += list[i].amount;
    }
    return total;
  }

  /// Cara 2: for-in
  static double totalForIn(List<Expense> list) {
    double total = 0;
    for (final e in list) {
      total += e.amount;
    }
    return total;
  }

  /// Cara 3: forEach (diubah agar tidak warning lint)
  static double totalForEach(List<Expense> list) {
    double total = 0;
    void addAmount(Expense e) {
      total += e.amount;
    }

    list.forEach(addAmount);
    return total;
  }

  /// Cara 4: fold
  static double totalFold(List<Expense> list) {
    return list.fold<double>(0, (sum, e) => sum + e.amount);
  }

  /// Cara 5: map + reduce
  static double totalReduce(List<Expense> list) {
    if (list.isEmpty) return 0;
    return list.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // ------------------------------
  // 2. Mencari item dengan berbagai cara
  // ------------------------------

  /// Cara 1: for loop + break
  static Expense? findExpenseTraditional(List<Expense> expenses, String id) {
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].id == id) {
        return expenses[i];
      }
    }
    return null;
  }

  /// Cara 2: firstWhere (lebih ringkas)
  static Expense? findExpenseWhere(List<Expense> expenses, String id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (_) {
      return null;
    }
  }

  // ------------------------------
  // 3. Filtering dengan berbagai cara
  // ------------------------------

  /// Cara 1: Loop manual dengan add()
  static List<Expense> filterByCategoryManual(
      List<Expense> expenses, String category) {
    List<Expense> result = [];
    for (Expense expense in expenses) {
      if (expense.category.toLowerCase() == category.toLowerCase()) {
        result.add(expense);
      }
    }
    return result;
  }

  /// Cara 2: Menggunakan where()
  static List<Expense> filterByCategoryWhere(
      List<Expense> expenses, String category) {
    return expenses
        .where((expense) =>
            expense.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
