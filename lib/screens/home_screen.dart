import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import 'login_screen.dart';
import 'expense_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // 🔽 KUNCI-NYA DI SINI: AnimatedBuilder akan rebuild
      // tiap kali ExpenseService (ChangeNotifier) memanggil notifyListeners().
      body: AnimatedBuilder(
        animation: svc,
        builder: (context, _) {
          final total = svc.totalAll; // selalu nilai terbaru
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: ListTile(
                    title: const Text('Total Pengeluaran'),
                    subtitle: const Text('Semua kategori & bulan'),
                    trailing: Text(
                      rp(total), // <- sekarang ikut berubah
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _card(
                        context,
                        'Expenses',
                        Icons.attach_money,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpenseListScreen(),
                          ),
                        ),
                      ),
                      _card(
                        context,
                        'Add Expense',
                        Icons.add_circle,
                        Colors.teal,
                        () async {
                          final ok = await Navigator.pushNamed(context, '/add');
                          if (ok == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengeluaran ditambahkan'),
                              ),
                            );
                          }
                        },
                      ),
                      _card(
                        context,
                        'Categories',
                        Icons.category,
                        Colors.indigo,
                        () => Navigator.pushNamed(context, '/categories'),
                      ),
                      _card(
                        context,
                        'Statistics',
                        Icons.bar_chart,
                        Colors.orange,
                        () => Navigator.pushNamed(context, '/stats'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
