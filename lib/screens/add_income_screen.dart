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
      ownerId: '',
      title: _titleC.text.trim(),
      amount: amt,
      date: _date,
      description: _descC.text.trim(),
    );

    svc.addIncome(inc);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IncomeSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2F7EF), Color(0xFFCA9EFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              children: [
                _sectionTitle('Title'),
                _textField(_titleC, hintText: 'Examples: Salary, Bonus, Gift',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title must be filled in' : null,
                ),
                const SizedBox(height: 20),

                _sectionTitle('Date'),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: _textField(
                      TextEditingController(text: '${_date.day}/${_date.month}/${_date.year}'),
                      hintText: 'Choose Date',
                      suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _sectionTitle('Amount'),
                _textField(
                  _amountC,
                  hintText: '0',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefix: const Text('Rp ', style: TextStyle(color: Colors.black)),
                  validator: (v) {
                    final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (d == null || d <= 0) return 'Enter a number > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _sectionTitle('Description (Optional)'),
                _textField(
                  _descC,
                  hintText: 'Additional information',
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );

  Widget _textField(
    TextEditingController controller, {
    required String hintText,
    Widget? suffixIcon,
    Widget? prefix,
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        prefix: prefix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines ?? 1,
    );
  }
}