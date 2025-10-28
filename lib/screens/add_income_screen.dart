import 'package:flutter/material.dart';
import 'package:individual_project_3g_samidkun_newest/screens/success_income_screen.dart';
import '../models/income.dart';
import '../services/income_service.dart';
import 'success_screen.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _amountC = TextEditingController();
  final _descC = TextEditingController();
  DateTime _date = DateTime.now();

  IncomeService get svc => IncomeService.instance;

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
    final inc = Income(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: '', // akan diisi oleh service sesuai current user
      title: _titleC.text.trim(),
      amount: amt,
      date: _date,
      description: _descC.text.trim(),
    );

    svc.addIncome(inc);

    // Arahkan ke layar sukses (sama seperti add expense)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IncomeSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 20),

            _sectionTitle('Title'),
            TextFormField(
              controller: _titleC,
              decoration: _input(hintText: 'Examples: Salary, Bonus, Gift'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title must be filled in' : null,
            ),
            const SizedBox(height: 24),

            _sectionTitle('Date'),
            TextFormField(
              readOnly: true,
              onTap: _pickDate,
              controller: TextEditingController(
                text: '${_date.day}/${_date.month}/${_date.year}',
              ),
              decoration: _input(
                hintText: 'Choose Date',
                suffixIcon:
                    const Icon(Icons.calendar_month_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Amount'),
            TextFormField(
              controller: _amountC,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _input(
                hintText: '0',
                prefix: const Text('Rp ', style: TextStyle(color: Colors.black)),
              ),
              validator: (v) {
                final d =
                    double.tryParse((v ?? '').replaceAll(',', '.'));
                if (d == null || d <= 0) return 'Enter a number > 0';
                return null;
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle('Description (Optional)'),
            TextFormField(
              controller: _descC,
              minLines: 3,
              maxLines: 5,
              decoration: _input(hintText: 'Additional information'),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // beda warna dari expense
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'Save Income',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helpers UI
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      );

  InputDecoration _input({
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
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
