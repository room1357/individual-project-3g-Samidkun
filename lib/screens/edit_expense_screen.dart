import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _titleC;
  late final TextEditingController _amountC;
  late final TextEditingController _descC;
  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.expense.title);
    _amountC = TextEditingController(text: widget.expense.amount.toString());
    _descC = TextEditingController(text: widget.expense.description);
    _category = widget.expense.category;
    _date = widget.expense.date;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    _descC.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.expense.copyWith(
      title: _titleC.text.trim(),
      amount: double.tryParse(_amountC.text.trim()) ?? widget.expense.amount,
      category: _category,
      date: _date,
      description: _descC.text.trim(),
      // ownerId TIDAK diubah → tetap milik pemilik lama
    );

    ExpenseService.instance.updateExpense(updated);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Center(child: ElevatedButton(onPressed: _save, child: const Text('Update'))),
    );
  }
}
