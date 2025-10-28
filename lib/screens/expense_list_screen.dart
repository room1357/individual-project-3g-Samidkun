// lib/screens/expense_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/currency_utils.dart';
import 'add_expense_screen.dart'; // <- pastikan ini ya, BUKAN AddIncomeScreen

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _query = '';
  String _selectedCategory = 'All';
  int _selectedMonth = 0; // 0 = All
  int _selectedYear = 0;  // 0 = All

  List<int> _yearOptions(List<Expense> items) {
    final years = {for (final e in items) e.date.year}..add(DateTime.now().year);
    final list = years.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  List<Expense> _applyFilters(List<Expense> src) {
    final q = _query.trim().toLowerCase();

    final filtered = src.where((e) {
      if (_selectedCategory != 'All' &&
          e.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      if (_selectedMonth > 0 && e.date.month != _selectedMonth) return false;
      if (_selectedYear > 0 && e.date.year != _selectedYear) return false;

      if (q.isNotEmpty) {
        final hay = '${e.title} ${e.description} ${e.category}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;

    return AnimatedBuilder(
      animation: svc,
      builder: (_, __) {
        // Pakai expenses (milik sendiri). Kalau ingin termasuk yang shared, ganti ke visibleExpenses.
        final all = svc.expenses;
        final filtered = _applyFilters(all);
        final total = filtered.fold<double>(0, (s, e) => s + e.amount);

        final categories = ['All', ...{for (final e in all) e.category}];
        final years = _yearOptions(all);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense List'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              Text('Total Expense', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                rp(total, context),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Search
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search by Title, Description, or Category',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: categories.contains(_selectedCategory) ? _selectedCategory : 'All',
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('All Months')),
                        DropdownMenuItem(value: 1, child: Text('January')),
                        DropdownMenuItem(value: 2, child: Text('February')),
                        DropdownMenuItem(value: 3, child: Text('March')),
                        DropdownMenuItem(value: 4, child: Text('April')),
                        DropdownMenuItem(value: 5, child: Text('May')),
                        DropdownMenuItem(value: 6, child: Text('June')),
                        DropdownMenuItem(value: 7, child: Text('July')),
                        DropdownMenuItem(value: 8, child: Text('August')),
                        DropdownMenuItem(value: 9, child: Text('September')),
                        DropdownMenuItem(value: 10, child: Text('October')),
                        DropdownMenuItem(value: 11, child: Text('November')),
                        DropdownMenuItem(value: 12, child: Text('December')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedMonth = v);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      items: [
                        const DropdownMenuItem(value: 0, child: Text('All Years')),
                        ...years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedYear = v);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No data matches the filter.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final e = filtered[i];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.pink.shade50,
                          child: SvgPicture.asset(
                            'assets/icons/expenses.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
                          ),
                        ),
                        title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${e.category} • ${e.formattedDate}'),
                        trailing: Text(
                          '- ${rp(e.amount, context)}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // TODO: open detail / edit if needed
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
