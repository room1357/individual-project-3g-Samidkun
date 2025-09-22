import '../models/expense.dart';

class ExpenseManager {
  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    final result = <String, double>{};
    for (final e in expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  static List<Expense> getExpensesByMonth(List<Expense> expenses, int month, int year) {
    return expenses.where((e) => e.date.month == month && e.date.year == year).toList();
  }

  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    final q = keyword.toLowerCase();
    return expenses.where((e) =>
        e.title.toLowerCase().contains(q) ||
        e.description.toLowerCase().contains(q) ||
        e.category.toLowerCase().contains(q)).toList();
  }

  static double getAverageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final uniqueDays = expenses
        .map((e) => '${e.date.year}-${e.date.month}-${e.date.day}')
        .toSet()
        .length;
    return total / uniqueDays;
  }
}
