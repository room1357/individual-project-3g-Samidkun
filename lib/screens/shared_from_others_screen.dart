// lib/screens/shared_from_others_screen.dart
import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/currency_utils.dart';
import '../services/user_directory_service.dart';

class SharedFromOthersScreen extends StatelessWidget {
  const SharedFromOthersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared from others'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: svc,
        builder: (context, _) {
          final items = svc.sharedToMe;
          if (items.isEmpty) {
            return const Center(child: Text('No data yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = items[i];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  // TANPA ICON/LEADING
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(e.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${e.category} • ${e.formattedDate}\n(Shared)',
                    maxLines: 2,
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    rp(e.amount, context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showDetail(context, e),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Helpers ---

  // Format nama pengirim: jika name == username (case-insensitive) tampilkan satu saja.
  String _formatUserLabel(dynamic u, String fallback) {
    if (u == null) return fallback;
    final name = (u.name ?? '').toString().trim();
    final uname = (u.username ?? '').toString().trim();
    if (name.isEmpty && uname.isEmpty) return fallback;
    if (name.isEmpty) return uname;
    if (uname.isEmpty) return name;
    return name.toLowerCase() == uname.toLowerCase() ? name : '$name ($uname)';
  }

  void _showDetail(BuildContext context, Expense e) {
    final u = UserDirectoryService.instance.findById(e.ownerId);
    final who = _formatUserLabel(u, e.ownerId); // tanpa '@' & hilangkan duplikasi

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(e.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Amount', rp(e.amount, context)),
            _row('Category', e.category),
            _row('Date', e.formattedDate),
            const Divider(height: 24),
            _row('Sent by', who),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(
                text: '$k: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: v),
            ],
          ),
        ),
      );
}
