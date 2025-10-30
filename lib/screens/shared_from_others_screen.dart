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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Shared from others'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEBFB), Color(0xFFD0C3FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBuilder(
          animation: svc,
          builder: (context, _) {
            final items = svc.sharedToMe;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'No shared expenses yet.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = items[i];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(e.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                    subtitle: Text(
                      '${e.category} • ${e.formattedDate}\n(Shared)',
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      rp(e.amount, context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    onTap: () => _showDetail(context, e),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- Helpers ---

  String _formatUserLabel(dynamic u, String fallback) {
    if (u == null) return fallback;
    final name = (u.name ?? '').trim();
    final uname = (u.username ?? '').trim();
    if (name.isEmpty && uname.isEmpty) return fallback;
    if (name.isEmpty) return uname;
    if (uname.isEmpty) return name;
    return name.toLowerCase() == uname.toLowerCase() ? name : '$name ($uname)';
  }

  void _showDetail(BuildContext context, Expense e) {
    final u = UserDirectoryService.instance.findById(e.ownerId);
    final who = _formatUserLabel(u, e.ownerId);

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
        padding: const EdgeInsets.symmetric(vertical: 6),
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
