import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/looping_examples.dart';
import '../utils/category_style.dart';
import '../utils/export_utils.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final ExpenseService svc = ExpenseService.instance;

  // Pencarian & Filter
  final TextEditingController _searchC = TextEditingController();
  String _selectedCategory = 'Semua';
  int _selectedMonth = 0; // 0 = Semua bulan
  int _selectedYear = 0;  // 0 = Semua tahun

  List<Expense> _visible = const [];

  List<String> get _categoryOptions => ['Semua', ...svc.categories.map((c) => c.name)];

  @override
  void initState() {
    super.initState();
    svc.addListener(_onServiceChanged);
    _applyFilter();
  }

  @override
  void dispose() {
    svc.removeListener(_onServiceChanged);
    _searchC.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    if (!_categoryOptions.contains(_selectedCategory)) {
      _selectedCategory = 'Semua';
    }
    setState(_applyFilter);
  }

  bool _isSemua(String v) => v.toLowerCase() == 'semua';

  void _applyFilter() {
    List<Expense> current = List.of(svc.expenses);

    if (_selectedMonth != 0 && _selectedYear != 0) {
      current = _getExpensesByMonth(current, _selectedMonth, _selectedYear);
    } else {
      if (_selectedMonth != 0) {
        current = current.where((e) => e.date.month == _selectedMonth).toList();
      }
      if (_selectedYear != 0) {
        current = current.where((e) => e.date.year == _selectedYear).toList();
      }
    }

    if (!_isSemua(_selectedCategory)) {
      final sel = _selectedCategory.toLowerCase();
      current = current.where((e) => e.category.toLowerCase() == sel).toList();
    }

    final q = _searchC.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      current = current.where((e) {
        return e.title.toLowerCase().contains(q) ||
               e.description.toLowerCase().contains(q) ||
               e.category.toLowerCase().contains(q);
      }).toList();
    }

    _visible = current;
  }

  @override
  Widget build(BuildContext context) {
    final totalPerCategory = _getTotalByCategory(_visible);
    final highest = _getHighestExpense(_visible);
    final averageDaily = _getAverageDaily(_visible); // <- dipakai di UI

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengeluaran'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            tooltip: 'Export PDF (sesuai filter)',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await ExportPdf.exportFromList(_visible, filename: 'expenses_filtered.pdf');
              if (!mounted) return; // <- guard setelah await
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF (filtered) siap. Silakan simpan/print.')),
              );
            },
          ),
          IconButton(
            tooltip: 'Demo Looping (Latihan 5)',
            icon: const Icon(Icons.calculate),
            onPressed: _showLoopingDemo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchC,
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan judul, deskripsi, atau kategori...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(_applyFilter),
            ),
          ),

          // Filter: Kategori / Bulan / Tahun
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    // FIX: value -> initialValue
                    initialValue: _categoryOptions.contains(_selectedCategory)
                        ? _selectedCategory
                        : 'Semua',
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _categoryOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCategory = v ?? 'Semua';
                        _applyFilter();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    // FIX: value -> initialValue
                    initialValue: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Semua')),
                      DropdownMenuItem(value: 1, child: Text('Jan')),
                      DropdownMenuItem(value: 2, child: Text('Feb')),
                      DropdownMenuItem(value: 3, child: Text('Mar')),
                      DropdownMenuItem(value: 4, child: Text('Apr')),
                      DropdownMenuItem(value: 5, child: Text('Mei')),
                      DropdownMenuItem(value: 6, child: Text('Jun')),
                      DropdownMenuItem(value: 7, child: Text('Jul')),
                      DropdownMenuItem(value: 8, child: Text('Agu')),
                      DropdownMenuItem(value: 9, child: Text('Sep')),
                      DropdownMenuItem(value: 10, child: Text('Okt')),
                      DropdownMenuItem(value: 11, child: Text('Nov')),
                      DropdownMenuItem(value: 12, child: Text('Des')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedMonth = v ?? 0;
                        _applyFilter();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    // FIX: value -> initialValue
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Semua')),
                      DropdownMenuItem(value: 2023, child: Text('2023')),
                      DropdownMenuItem(value: 2024, child: Text('2024')),
                      DropdownMenuItem(value: 2025, child: Text('2025')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedYear = v ?? 0;
                        _applyFilter();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Header + statistik
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
            ),
            child: Column(
              children: [
                Text('Total Pengeluaran',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                Text(
                  'Rp ${_visible.fold<double>(0.0, (s, e) => s + e.amount).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total per Kategori:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: totalPerCategory.entries
                      .map((e) => Chip(
                            label: Text('${e.key}: Rp ${e.value.toStringAsFixed(0)}'),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.blue.shade200),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                if (highest != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tertinggi: ${highest.title} (${highest.formattedAmount})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // FIX: pakai variabel averageDaily
                    'Rata-rata Harian: Rp ${averageDaily.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _visible.isEmpty
                ? const Center(child: Text('Tidak ada data sesuai filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _visible.length,
                    itemBuilder: (context, index) {
                      final expense = _visible[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: categoryColor(expense.category),
                            child: Icon(
                              categoryIcon(expense.category),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.category,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              Text(
                                expense.formattedDate,
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
                          onTap: () => _showExpenseDetails(context, expense),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.pushNamed(context, '/add');
          if (!mounted) return;            // <- guard setelah await
          if (ok == true) setState(_applyFilter);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Latihan 5 demo
  void _showLoopingDemo() {
    final forIndex = LoopingExamples.totalForIndex(_visible);
    final forIn = LoopingExamples.totalForIn(_visible);
    final forEach = LoopingExamples.totalForEach(_visible);
    final fold = LoopingExamples.totalFold(_visible);
    final reduce = LoopingExamples.totalReduce(_visible);

    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        Expense? foundTraditional;
        Expense? foundWhere;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Latihan 5: Demo Looping & Pencarian'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('=== Total dengan Berbagai Cara ==='),
                  Text('for (index): Rp ${forIndex.toStringAsFixed(0)}'),
                  Text('for-in: Rp ${forIn.toStringAsFixed(0)}'),
                  Text('forEach: Rp ${forEach.toStringAsFixed(0)}'),
                  Text('fold: Rp ${fold.toStringAsFixed(0)}'),
                  Text('reduce: Rp ${reduce.toStringAsFixed(0)}'),
                  const SizedBox(height: 16),

                  const Text('=== Pencarian Data Berdasarkan ID ==='),
                  TextField(
                    controller: idController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Masukkan ID (contoh: 1, 2, 3...)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val.isNotEmpty) {
                          foundTraditional =
                              LoopingExamples.findExpenseTraditional(_visible, val);
                          foundWhere =
                              LoopingExamples.findExpenseWhere(_visible, val);
                        } else {
                          foundTraditional = null;
                          foundWhere = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  if (foundTraditional != null || foundWhere != null) ...[
                    Text('Manual Loop: ${foundTraditional?.title ?? "Tidak ditemukan"}'),
                    Text('firstWhere: ${foundWhere?.title ?? "Tidak ditemukan"}'),
                  ],

                  const SizedBox(height: 16),
                  const Text('=== Filter Kategori "Transportasi" ==='),
                  Text(
                    'Manual: ${LoopingExamples.filterByCategoryManual(_visible, "Transportasi").length} item',
                  ),
                  Text(
                    'where(): ${LoopingExamples.filterByCategoryWhere(_visible, "Transportasi").length} item',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
            ],
          );
        });
      },
    );
  }

  // Helpers
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
            const SizedBox(height: 8),
            Text('Kategori: ${expense.category}'),
            const SizedBox(height: 8),
            Text('Tanggal: ${expense.formattedDate}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${expense.description}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Map<String, double> _getTotalByCategory(List<Expense> list) {
    final map = <String, double>{};
    for (final e in list) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  Expense? _getHighestExpense(List<Expense> list) {
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  List<Expense> _getExpensesByMonth(List<Expense> list, int month, int year) {
    return list.where((e) => e.date.month == month && e.date.year == year).toList();
  }

  double _getAverageDaily(List<Expense> list) {
    if (list.isEmpty) return 0.0;
    final total = list.fold<double>(0.0, (sum, e) => sum + e.amount);
    final uniqueDays =
        list.map((e) => '${e.date.year}-${e.date.month}-${e.date.day}').toSet().length;
    return uniqueDays == 0 ? 0.0 : total / uniqueDays;
  }
}
