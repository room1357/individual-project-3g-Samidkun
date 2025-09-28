import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/date_utils.dart';

class EditExpenseScreen extends StatefulWidget {
  final String expenseId;
  const EditExpenseScreen({super.key, required this.expenseId});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _amountC = TextEditingController();
  final _descC = TextEditingController();
  DateTime _date = DateTime.now();
  String? _catId;

  Expense? _orig;

  @override
  void initState() {
    super.initState();
    final svc = ExpenseService.instance;
    _orig = svc.getById(widget.expenseId);
    if (_orig != null) {
      _titleC.text = _orig!.title;
      _amountC.text = _orig!.amount.toStringAsFixed(0);
      _descC.text = _orig!.description;
      _date = _orig!.date;
      final cat = svc.categories.firstWhere((c) => c.name == _orig!.category, orElse: () => svc.categories.first);
      _catId = cat.id;
    } else {
      if (svc.categories.isNotEmpty) _catId = svc.categories.first.id;
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (_orig == null) return;
    if (!_formKey.currentState!.validate()) return;
    final svc = ExpenseService.instance;
    final cat = svc.categories.firstWhere((c) => c.id == _catId, orElse: () => svc.categories.first);
    final amount = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0;

    svc.updateExpense(Expense(
      id: _orig!.id,
      title: _titleC.text.trim(),
      amount: amount,
      category: cat.name,
      date: _date,
      description: _descC.text.trim(),
    ));
    Navigator.pop(context, true);
  }

  void _delete() {
    if (_orig == null) return;
    ExpenseService.instance.deleteExpense(_orig!.id);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    final cats = svc.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengeluaran')),
      body: _orig == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleC,
                      decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder()),
                      validator: (v) {
                        final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (d == null || d <= 0) return 'Masukkan jumlah yang valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _catId,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => _catId = v),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tanggal', border: OutlineInputBorder()),
                        child: Text(formatYmd(_date)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descC,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Simpan'))),
                        const SizedBox(width: 8),
                        Expanded(child: OutlinedButton(onPressed: _delete, child: const Text('Hapus'))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
