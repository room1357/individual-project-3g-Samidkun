import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/export_utils.dart'; // Asumsi file export PDF Anda di sini

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  Future<void> _exportAsCsv(BuildContext context) async {
    final List<Expense> expenses = ExpenseService.instance.expenses;
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport.')),
      );
      return;
    }

    List<List<dynamic>> rows = [
      ['Title', 'Amount', 'Category', 'Date', 'Description'],
    ];

    for (var expense in expenses) {
      rows.add([
        expense.title,
        expense.amount,
        expense.category,
        expense.formattedDate,
        expense.description,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    await Share.share(csv, subject: 'Export_Expenses.csv');
  }

  Future<void> _exportAsPdf(BuildContext context) async {
    final List<Expense> expenses = ExpenseService.instance.expenses;
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no data to export.')),
      );
      return;
    }

    await ExportPdf.exportFromList(
      expenses,
      filename: 'all_expenses.pdf',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The PDF is ready. Please save/print it.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCBF1F5), Color(0xFFD4C1EC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Export Format',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You can save all your expense data in PDF format for reporting or CSV format for further processing in a spreadsheet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                const Spacer(),

                // Tombol Export PDF
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Export As PDF'),
                  onPressed: () => _exportAsPdf(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B5DE5), // Ungu
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Export CSV
                ElevatedButton.icon(
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Export As CSV'),
                  onPressed: () => _exportAsCsv(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
