import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data sample menggunakan List<Expense>
    final List<Expense> expenses = [
      Expense(
        id: '1',
        title: 'Belanja Bulanan',
        amount: 150000,
        category: 'Makanan',
        date: DateTime(2024, 9, 15),
        description: 'Belanja kebutuhan bulanan di supermarket',
      ),
      Expense(
        id: '2',
        title: 'Bensin Motor',
        amount: 50000,
        category: 'Transportasi',
        date: DateTime(2024, 9, 14),
        description: 'Isi bensin motor untuk transportasi',
      ),
      Expense(
        id: '3',
        title: 'Kopi di Cafe',
        amount: 25000,
        category: 'Makanan',
        date: DateTime(2024, 9, 14),
        description: 'Ngopi pagi dengan teman',
      ),
      Expense(
        id: '4',
        title: 'Tagihan Internet',
        amount: 300000,
        category: 'Utilitas',
        date: DateTime(2024, 9, 13),
        description: 'Tagihan internet bulanan',
      ),
      Expense(
        id: '5',
        title: 'Tiket Bioskop',
        amount: 100000,
        category: 'Hiburan',
        date: DateTime(2024, 9, 12),
        description: 'Nonton film weekend bersama keluarga',
      ),
      Expense(
        id: '6',
        title: 'Beli Buku',
        amount: 75000,
        category: 'Pendidikan',
        date: DateTime(2024, 9, 11),
        description: 'Buku pemrograman untuk belajar',
      ),
      Expense(
        id: '7',
        title: 'Makan Siang',
        amount: 35000,
        category: 'Makanan',
        date: DateTime(2024, 9, 11),
        description: 'Makan siang di restoran',
      ),
      Expense(
        id: '8',
        title: 'Ongkos Bus',
        amount: 10000,
        category: 'Transportasi',
        date: DateTime(2024, 9, 10),
        description: 'Ongkos perjalanan harian ke kampus',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengeluaran'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Header dengan total pengeluaran
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total Pengeluaran',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _calculateTotal(expenses),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // ListView untuk menampilkan daftar pengeluaran
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(expense.category),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      expense.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          expense.formattedDate,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      expense.formattedAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red[600],
                      ),
                    ),
                    onTap: () {
                      _showExpenseDetails(context, expense);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fitur tambah pengeluaran segera hadir!')),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  // Method untuk menghitung total menggunakan fold()
  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  // Method untuk mendapatkan warna berdasarkan kategori
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.green;
      case 'utilitas':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'pendidikan':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Method untuk mendapatkan icon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'utilitas':
        return Icons.home;
      case 'hiburan':
        return Icons.movie;
      case 'pendidikan':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }

  // Method untuk menampilkan detail pengeluaran dalam dialog
  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah: ${expense.formattedAmount}'),
            SizedBox(height: 8),
            Text('Kategori: ${expense.category}'),
            SizedBox(height: 8),
            Text('Tanggal: ${expense.formattedDate}'),
            SizedBox(height: 8),
            Text('Deskripsi: ${expense.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}