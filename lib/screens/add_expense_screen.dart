import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

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
  String? _category; // dipilih dari dropdown

  ExpenseService get svc => ExpenseService.instance;

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
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amt = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0;
    final exp = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: '', // akan diisi oleh service lewat copyWith(ownerId)
      title: _titleC.text.trim(),
      amount: amt,
      category: _category ?? 'Lainnya',
      date: _date,
      description: _descC.text.trim(),
      sharedWith: const [],
    );

    svc.addExpense(exp);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categories = svc.categories; // bisa kosong
    final catItems = categories.map((c) => c.name).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Judul
              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Jumlah
              TextFormField(
                controller: _amountC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (angka)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (d == null || d <= 0) return 'Masukkan angka > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Kategori (dropdown) + fallback jika kosong
              if (catItems.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _category ?? catItems.first,
                  items: catItems
                      .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _category = v),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    color: Colors.orange.withOpacity(.06),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Belum ada kategori. Tambahkan kategori dulu.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/categories'),
                        child: const Text('Kelola'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tanggal
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(),
                  ),
                  child: Text('${_date.day}/${_date.month}/${_date.year}'),
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi
              TextFormField(
                controller: _descC,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (catItems.isEmpty) ? null : _save,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
