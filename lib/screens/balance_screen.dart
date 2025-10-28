import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../utils/currency_utils.dart';
import '../utils/category_style.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expSvc = ExpenseService.instance;
    final incSvc = IncomeService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Balance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        // rebuild kalau income ATAU expense berubah
        animation: Listenable.merge([expSvc, incSvc]),
        builder: (context, _) {
          final totalIncome = incSvc.totalAll;
          final totalExpense = expSvc.totalAll;
          final balance = totalIncome - totalExpense;

          // sort terbaru
          final latestIncomes = List<Income>.of(incSvc.incomes)
            ..sort((a, b) => b.date.compareTo(a.date));
          final latestExpenses = List<Expense>.of(expSvc.expenses)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // KPI cards
              Row(
                children: [
                  Expanded(
                    child: _kpiCard(
                      title: 'Total Income',
                      valueText: '+ ${rp(totalIncome, context)}',
                      color: Colors.green,
                      icon: Icons.south_west, // panah masuk
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kpiCard(
                      title: 'Total Expense',
                      valueText: '- ${rp(totalExpense, context)}',
                      color: Colors.red,
                      icon: Icons.north_east, // panah keluar
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _kpiCard(
                title: 'Balance',
                valueText: rp(balance, context),
                color: balance >= 0 ? Colors.teal : Colors.red,
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 28),

              // Lists
              const Text('Latest Incomes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (latestIncomes.isEmpty)
                const _EmptyHint(text: 'There has been no income yet.')
              else
                ...latestIncomes.take(5).map(
  (i) => _incomeDismissible(context, i, incSvc),
),

              const SizedBox(height: 24),
              const Text('Latest Spending',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (latestExpenses.isEmpty)
                const _EmptyHint(text: 'No expenses yet.')
              else
                ...latestExpenses.take(5).map((e) => _expenseTile(context, e)),
            ],
          );
        },
      ),
    );
  }

  // ---------- Widgets kecil ----------

  static Widget _kpiCard({
    required String title,
    required String valueText,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: color.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 6),
                Text(valueText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _incomeTile(BuildContext context, Income i) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.12),
          child: const Icon(Icons.south_west, color: Colors.green),
        ),
        title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${i.formattedDate}${i.description.isNotEmpty ? ' • ${i.description}' : ''}'),
        trailing: Text(
          '+ ${rp(i.amount, context)}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
Widget _incomeDismissible(
  BuildContext context,
  Income i,
  IncomeService incSvc,
) {
  return Dismissible(
    key: ValueKey('inc_${i.id}'),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    ),
    confirmDismiss: (direction) async {
      return await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete income?'),
              content: Text('“${i.title}” will be deleted.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ) ??
          false;
    },
    onDismissed: (_) {
      final removed = i;
      incSvc.deleteIncome(removed.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income "${removed.title}" Deleted'),
          action: SnackBarAction(
            label: 'CANCEL',
            onPressed: () {
              incSvc.addIncome(removed);
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    },
    child: _incomeTile(context, i),
  );
}



  static Widget _expenseTile(BuildContext context, Expense e) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: categoryAvatar(e.category, size: 40),
        title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${e.category} • ${e.formattedDate}${e.description.isNotEmpty ? ' • ${e.description}' : ''}'),
        trailing: Text(
          '- ${rp(e.amount, context)}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
