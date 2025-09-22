import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/looping_examples.dart'; // <<< Latihan 5: import utils

/// Daftar Pengeluaran — Latihan 3, 4, 5
/// - Latihan 3: total per kategori, tertinggi, rata-rata harian
/// - Latihan 4: pencarian & filter (kategori/bulan/tahun)
/// - Latihan 5: berbagai cara looping untuk hitung total
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  // ----------------------------
  // Kontrol Pencarian & Filter
  // ----------------------------
  final TextEditingController _searchC = TextEditingController();

  final List<String> _categories = const [
    'Semua',
    'Makanan',
    'Transportasi',
    'Utilitas',
    'Hiburan',
    'Pendidikan',
  ];

  late String _selectedCategory; // di-init 'Semua'
  int _selectedMonth = 0; // 0 = Semua bulan
  int _selectedYear = 0;  // 0 = Semua tahun

  // ----------------------------
  // Data contoh (kategori Indonesia)
  // ----------------------------
  final List<Expense> _expenses = [
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

  /// List yang terlihat setelah filter & search diterapkan
  late List<Expense> _visible;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first; // 'Semua'
    _selectedMonth = 0;
    _selectedYear = 0;
    _searchC.clear();

    _visible = List.of(_expenses);
    _applyFilter(); // render awal
  }

  bool _isSemua(String v) => v.toLowerCase() == 'semua';

  // ----------------------------
  // Inti filter terpadu (Latihan 4)
  // ----------------------------
  void _applyFilter() {
    List<Expense> current = List.of(_expenses);

    // Jika bulan & tahun dipilih bersamaan → pakai helper bulan&tahun
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

    // Filter kategori (skip jika "Semua")
    if (!_isSemua(_selectedCategory)) {
      current = current.where((e) => e.category == _selectedCategory).toList();
    }

    // Pencarian teks (judul / deskripsi / kategori) — pakai helper
    final q = _searchC.text.trim();
    if (q.isNotEmpty) {
      current = _searchExpenses(current, q);
    }

    setState(() => _visible = current);
  }

  @override
  Widget build(BuildContext context) {
    // ----------------------------
    // Nilai terhitung (Latihan 3)
    // ----------------------------
    final totalPerCategory = _getTotalByCategory(_visible);
    final highest = _getHighestExpense(_visible);
    final averageDaily = _getAverageDaily(_visible);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengeluaran'),
        backgroundColor: Colors.blue,
        actions: [
          // Latihan 5: tombol demo looping
          IconButton(
            tooltip: 'Demo Looping (Latihan 5)',
            icon: const Icon(Icons.calculate),
            onPressed: _showLoopingDemo,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Kolom pencarian ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchC,
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan judul, deskripsi, atau kategori...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _applyFilter(),
            ),
          ),

          // --- Baris filter: Kategori / Bulan / Tahun ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      _selectedCategory = v ?? 'Semua';
                      _applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
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
                      _selectedMonth = v ?? 0;
                      _applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
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
                      _selectedYear = v ?? 0;
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- Header + statistik ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Text(
                  _formatCurrency(
                    _visible.fold<double>(0, (s, e) => s + e.amount),
                  ),
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
                  children: totalPerCategory.entries.map((e) {
                    return Chip(
                      label: Text('${e.key}: ${_formatCurrency(e.value)}'),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.blue.shade200),
                    );
                  }).toList(),
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
                    'Rata-rata Harian: ${_formatCurrency(averageDaily)}',
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

          // --- List pengeluaran ---
          Expanded(
            child: _visible.isEmpty
                ? const Center(child: Text('Tidak ada data sesuai filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _visible.length,
                    itemBuilder: (context, index) {
                      final expense = _visible[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
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
                          onTap: () => _showExpenseDetails(context, expense),
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
            const SnackBar(content: Text('Fitur tambah pengeluaran segera hadir!')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ----------------------------
  // Latihan 5: tampilkan hasil looping
  // ----------------------------
  void _showLoopingDemo() {
  final forIndex = LoopingExamples.totalForIndex(_visible);
  final forIn = LoopingExamples.totalForIn(_visible);
  final forEach = LoopingExamples.totalForEach(_visible);
  final fold = LoopingExamples.totalFold(_visible);
  final reduce = LoopingExamples.totalReduce(_visible);

  // Controller untuk input ID
  final TextEditingController idController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      // Variabel hasil pencarian
      Expense? foundTraditional;
      Expense? foundWhere;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Latihan 5: Demo Looping & Pencarian'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('=== Total dengan Berbagai Cara ==='),
                  Text('for (index): ${_formatCurrency(forIndex)}'),
                  Text('for-in: ${_formatCurrency(forIn)}'),
                  Text('forEach: ${_formatCurrency(forEach)}'),
                  Text('fold: ${_formatCurrency(fold)}'),
                  Text('reduce: ${_formatCurrency(reduce)}'),
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
                          foundTraditional = LoopingExamples.findExpenseTraditional(_visible, val);
                          foundWhere = LoopingExamples.findExpenseWhere(_visible, val);
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
                  const Text('=== Filter Kategori "Makanan" ==='),
                  Text(
                    'Manual: ${LoopingExamples.filterByCategoryManual(_visible, "Makanan").length} item',
                  ),
                  Text(
                    'where(): ${LoopingExamples.filterByCategoryWhere(_visible, "Makanan").length} item',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    },
  );
}


  // ----------------------------
  // Helper tampilan
  // ----------------------------
  String _formatCurrency(double value) => 'Rp ${value.toStringAsFixed(0)}';

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Helper manipulasi data (Latihan 3)
  // ----------------------------
  Map<String, double> _getTotalByCategory(List<Expense> list) {
    final map = <String, double>{};
    for (final e in list) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
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

  List<Expense> _searchExpenses(List<Expense> list, String keyword) {
    final q = keyword.toLowerCase();
    return list.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
    }).toList();
  }

  double _getAverageDaily(List<Expense> list) {
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (sum, e) => sum + e.amount);
    final uniqueDays =
        list.map((e) => '${e.date.year}-${e.date.month}-${e.date.day}').toSet().length;
    return uniqueDays == 0 ? 0 : total / uniqueDays;
  }
}
