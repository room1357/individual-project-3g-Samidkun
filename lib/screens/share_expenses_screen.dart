// lib/screens/share_expenses_screen.dart
import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class ShareExpensesScreen extends StatefulWidget {
  const ShareExpensesScreen({super.key});

  @override
  State<ShareExpensesScreen> createState() => _ShareExpensesScreenState();
}

class _ShareExpensesScreenState extends State<ShareExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameC = TextEditingController();

  @override
  void dispose() {
    _usernameC.dispose();
    super.dispose();
  }

  String _sanitize(String input) =>
      input.trim().replaceAll('@', '').replaceAll(' ', '');

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _doShare() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final target = _sanitize(_usernameC.text);
    final count = await ExpenseService.instance.shareAllToUsername(target);
    if (!mounted) return;

    if (count > 0) {
      _showSnack('Successfully shared $count expenses to $target',
          color: Colors.green);
      _usernameC.clear();
    } else {
      _showSnack(
        'No changes (incorrect username / already shared / empty).',
        color: Colors.redAccent,
      );
    }
  }

  Future<void> _doUnshare() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final target = _sanitize(_usernameC.text);
    final count = await ExpenseService.instance.unshareAllFromUsername(target);
    if (!mounted) return;

    if (count > 0) {
      _showSnack('Stop sharing $count expenses to $target',
          color: Colors.orange);
    } else {
      _showSnack('No changes (perhaps never shared).',
          color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Expenses'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Share ALL your expenses so other users can VIEW them (read-only).',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameC,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Destination username',
                hintText: 'Example : KUNGKINGKANG',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || _sanitize(v).isEmpty) ? 'Username must be filled in' : null,
              onFieldSubmitted: (_) => _doShare(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _doShare,
              icon: const Icon(Icons.share),
              label: const Text('Share ALL expenses'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _doUnshare,
              child: const Text('Stop sharing to this user'),
            ),
          ],
        ),
      ),
    );
  }
}
