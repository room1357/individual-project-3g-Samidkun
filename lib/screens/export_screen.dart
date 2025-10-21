// File: lib/screens/export_screen.dart

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/export_utils.dart'; // Asumsi file export PDF Anda di sini

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  // Fungsi untuk handle export ke CSV
  Future<void> _exportAsCsv(BuildContext context) async {
    final List<Expense> expenses = ExpenseService.instance.expenses;
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport.')),
      );
      return;
    }

    // Menyiapkan data untuk CSV
    // Baris pertama adalah header
    List<List<dynamic>> rows = [
      ['Judul', 'Jumlah', 'Kategori', 'Tanggal', 'Deskripsi']
    ];

    // Baris selanjutnya adalah data expense
    for (var expense in expenses) {
      rows.add([
        expense.title,
        expense.amount,
        expense.category,
        expense.formattedDate,
        expense.description,
      ]);
    }

    // Mengubah list menjadi string CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Menggunakan share_plus untuk membagikan string sebagai file
    await Share.share(csv, subject: 'Export_Pengeluaran.csv');
  }

  // Fungsi untuk handle export ke PDF
  Future<void> _exportAsPdf(BuildContext context) async {
    final List<Expense> expenses = ExpenseService.instance.expenses;
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport.')),
      );
      return;
    }

    // Memanggil fungsi export PDF yang sudah ada
    await ExportPdf.exportFromList(
      expenses,
      filename: 'semua_pengeluaran.pdf',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF siap. Silakan simpan/print.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih Format Export',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Anda dapat menyimpan semua data pengeluaran Anda dalam format PDF untuk laporan atau CSV untuk diolah lebih lanjut di spreadsheet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(), // Mendorong tombol ke tengah
            
            // Tombol Export PDF
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Export sebagai PDF'),
              onPressed: () => _exportAsPdf(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Export CSV
            ElevatedButton.icon(
              icon: const Icon(Icons.grid_on_outlined),
              label: const Text('Export sebagai CSV'),
              onPressed: () => _exportAsCsv(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            const Spacer(), // Mendorong tombol ke tengah
          ],
        ),
      ),
    );
  }
}