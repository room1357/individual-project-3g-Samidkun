import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/date_utils.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _amountC = TextEditingController();
  final _descC = TextEditingController();
  DateTime _date = DateTime.now();
  String? _catId; // pakai name untuk category di service (sederhana)

  @override
  void initState() {
    super.initState();
    final cats = ExpenseService.instance.categories;
    _catId = cats.isNotEmpty ? cats.first.id : null;
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
    if (!_formKey.currentState!.validate()) return;
    final svc = ExpenseService.instance;
    final cat = svc.categories.firstWhere((c) => c.id == _catId);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final amount = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0;

    svc.addExpense(Expense(
      id: id,
      title: _titleC.text.trim(),
      amount: amount,
      category: cat.name,
      date: _date,
      description: _descC.text.trim(),
    ));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    final cats = svc.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengeluaran')),
      body: Padding(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _save, child: const Text('Simpan')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
