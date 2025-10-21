import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'success_screen.dart';
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Semua state dan controller lama dipertahankan
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _amountC = TextEditingController();
  final _descC = TextEditingController();
  DateTime _date = DateTime.now();
  String? _category;

  ExpenseService get svc => ExpenseService.instance;

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    _descC.dispose();
    super.dispose();
  }

  // Semua fungsi logika (_pickDate, _save) tidak berubah
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
      ownerId: '',
      title: _titleC.text.trim(),
      amount: amt,
      category: _category ?? 'Lainnya',
      date: _date,
      description: _descC.text.trim(),
    );

    svc.addExpense(exp);
  // Di dalam fungsi _save() pada add_expense_screen.dart

// SESUDAH
// Ganti navigasi pop dengan pushReplacement ke halaman sukses
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const SuccessScreen()),
);
  }

  // [DIUBAH] Seluruh build method dirombak
  @override
  Widget build(BuildContext context) {
    final categories = svc.categories;
    final catItems = categories.map((c) => c.name).toList();
    if (_category == null && catItems.isNotEmpty) {
      _category = catItems.first;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Tambah Pengeluaran'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 20),

            // [UI BARU] Field Pengeluaran (Judul)
            _buildSectionTitle('Pengeluaran'),
            TextFormField(
              controller: _titleC,
              decoration: _buildInputDecoration(hintText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pengeluaran wajib diisi' : null,
            ),
            const SizedBox(height: 24),

            // [UI BARU] Field Tanggal
            _buildSectionTitle('Date'),
            TextFormField(
              readOnly: true, // Membuat field tidak bisa diketik
              onTap: _pickDate,
              controller: TextEditingController(text: '${_date.day}/${_date.month}/${_date.year}'),
              decoration: _buildInputDecoration(
                hintText: 'Pilih Tanggal',
                suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // [UI BARU] Field Jumlah
            _buildSectionTitle('Amount'),
            TextFormField(
              controller: _amountC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _buildInputDecoration(
                hintText: '0',
                prefix: const Text('Rp ', style: TextStyle(color: Colors.black)),
              ),
              validator: (v) {
                final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (d == null || d <= 0) return 'Masukkan jumlah lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // [UI BARU] Field Kategori
            _buildSectionTitle('Category'),
            if (catItems.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _category,
                items: catItems.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                onChanged: (v) => setState(() => _category = v),
                decoration: _buildInputDecoration(hintText: 'Pilih Kategori'),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              )
            else
              // Fallback jika tidak ada kategori
              const Text('Tidak ada kategori. Silakan tambah kategori terlebih dahulu.'),
            const SizedBox(height: 24),

            // [UI BARU] Field Deskripsi
            _buildSectionTitle('Description (Optional)'),
            TextFormField(
              controller: _descC,
              minLines: 3,
              maxLines: 5,
              decoration: _buildInputDecoration(hintText: 'Deskripsi Tambahan'),
            ),
            const SizedBox(height: 40),

            // [UI BARU] Tombol Simpan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: catItems.isEmpty ? null : _save,
              child: const Text('Simpan Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget untuk UI Baru ---

  // Helper untuk membuat judul setiap section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }

  // Helper untuk membuat style input field yang konsisten
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefix: prefix,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Menghilangkan border
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}