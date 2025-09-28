import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'expense_list_screen.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/export_utils.dart';

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
              // Logout: kembali ke Login dan hapus semua route sebelumnya
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Total
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
                  rp(svc.totalAll),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Grid menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  // 1) Expenses (daftar + edit dari screen kamu)
                  _buildDashboardCard(
                    'Expenses',
                    Icons.attach_money,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExpenseListScreen(),
                        ),
                      );
                    },
                  ),

                  // 2) Add Expense
                  _buildDashboardCard(
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

                  // 3) Categories (kelola kategori)
                  _buildDashboardCard(
                    'Categories',
                    Icons.category,
                    Colors.indigo,
                    () {
                      Navigator.pushNamed(context, '/categories');
                    },
                  ),

                  // 4) Statistics (grafik & ringkasan)
                  _buildDashboardCard(
                    'Statistics',
                    Icons.bar_chart,
                    Colors.orange,
                    () {
                      Navigator.pushNamed(context, '/stats');
                    },
                  ),

                  // 5) Export PDF (baru)
                  _buildDashboardCard(
                    'Export PDF',
                    Icons.picture_as_pdf,
                    Colors.red,
                    () async {
                      await ExportPdf.exportAll(filename: 'expenses.pdf');
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PDF diekspor. Silakan simpan/print.'),
                        ),
                      );
                    },
                  ),

                  // 6) Setting (placeholder)
                  _buildDashboardCard(
                    'Setting',
                    Icons.settings,
                    Colors.purple,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature Setting coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 4,
      child: Builder(
        builder: (context) => InkWell(
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feature $title coming soon!')),
                );
              },
          child: Container(
            padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}
