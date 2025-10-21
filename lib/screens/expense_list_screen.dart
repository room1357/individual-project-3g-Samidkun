import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/category_style.dart';
import '../utils/currency_utils.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final ExpenseService svc = ExpenseService.instance;

  // State untuk filter & search
  final TextEditingController _searchC = TextEditingController();
  String _selectedCategory = 'Semua';
  int _selectedMonth = 0;
  int _selectedYear = 0;

  List<Expense> _visible = const [];

  List<String> get _categoryOptions => ['Semua', ...svc.categories.map((c) => c.name)];

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan dari service
    svc.addListener(_onServiceChanged);
    // Terapkan filter untuk pertama kali
    _applyFilter();
  }

  @override
  void dispose() {
    svc.removeListener(_onServiceChanged);
    _searchC.dispose();
    super.dispose();
  }

  // Fungsi ini akan dipanggil setiap kali ada perubahan data di service
  void _onServiceChanged() {
    if (!mounted) return;
    // Jika kategori yang dipilih dihapus, reset ke 'Semua'
    if (!_categoryOptions.contains(_selectedCategory)) {
      _selectedCategory = 'Semua';
    }
    // Terapkan ulang filter dengan data baru
    setState(_applyFilter);
  }

  // Helper untuk cek filter 'Semua'
  bool _isSemua(String v) => v.toLowerCase() == 'semua';

  // Logika filter utama
  void _applyFilter() {
    List<Expense> current = List.of(svc.expenses);
    final q = _searchC.text.trim().toLowerCase();

    // Filter berdasarkan tahun
    if (_selectedYear != 0) {
      current = current.where((e) => e.date.year == _selectedYear).toList();
    }

    // Filter berdasarkan bulan
    if (_selectedMonth != 0) {
      current = current.where((e) => e.date.month == _selectedMonth).toList();
    }

    // Filter berdasarkan kategori
    if (!_isSemua(_selectedCategory)) {
      final sel = _selectedCategory.toLowerCase();
      current = current.where((e) => e.category.toLowerCase() == sel).toList();
    }
    
    // Filter berdasarkan query pencarian
    if (q.isNotEmpty) {
      current = current.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q);
      }).toList();
    }

    setState(() {
      _visible = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _visible.fold<double>(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        },
        backgroundColor: Colors.pinkAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text('Daftar Pengeluaran', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTotalCard(total),
            const SizedBox(height: 30),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterRow(),
            const SizedBox(height: 30),
            if (_visible.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Tidak ada data sesuai filter.'),
                ),
              )
            else
              ListView.separated(
                itemCount: _visible.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const Divider(height: 24, color: Colors.transparent),
                itemBuilder: (context, index) {
                  final expense = _visible[index];
                  
                  return Dismissible(
                    key: Key(expense.id),
                    background: Container(
                      color: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Konfirmasi Hapus"),
                            content: const Text("Apakah Anda yakin ingin menghapus pengeluaran ini?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      svc.deleteExpense(expense.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${expense.title} berhasil dihapus'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        categoryAvatar(expense.category, size: 45),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${expense.category} • ${expense.formattedDate}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text('- ${rp(expense.amount, context)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget untuk UI ---

  Widget _buildTotalCard(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Total Pengeluaran', style: TextStyle(color: Colors.grey, fontSize: 16)),
        Text(rp(total, context), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchC,
        decoration: const InputDecoration(
          hintText: 'Cari Berdasarkan Judul, Deskripsi, atau Kategori',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (_) => _applyFilter(),
      ),
    );
  }

  Widget _buildFilterRow() {
    final List<DropdownMenuItem<int>> monthItems = [
      const DropdownMenuItem(value: 0, child: Text('Semua Bulan')),
      const DropdownMenuItem(value: 1, child: Text('Januari')),
      const DropdownMenuItem(value: 2, child: Text('Februari')),
      const DropdownMenuItem(value: 3, child: Text('Maret')),
      const DropdownMenuItem(value: 4, child: Text('April')),
      const DropdownMenuItem(value: 5, child: Text('Mei')),
      const DropdownMenuItem(value: 6, child: Text('Juni')),
      const DropdownMenuItem(value: 7, child: Text('Juli')),
      const DropdownMenuItem(value: 8, child: Text('Agustus')),
      const DropdownMenuItem(value: 9, child: Text('September')),
      const DropdownMenuItem(value: 10, child: Text('Oktober')),
      const DropdownMenuItem(value: 11, child: Text('November')),
      const DropdownMenuItem(value: 12, child: Text('Desember')),
    ];

    final int currentYear = DateTime.now().year;
    final List<DropdownMenuItem<int>> yearItems = [
      const DropdownMenuItem(value: 0, child: Text('Semua Tahun')),
      ...List.generate(5, (index) {
        final year = currentYear - index;
        return DropdownMenuItem(value: year, child: Text(year.toString()));
      })
    ];

    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedCategory,
            items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) {
              setState(() {
                _selectedCategory = v ?? 'Semua';
                _applyFilter();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            value: _selectedMonth,
            items: monthItems,
            onChanged: (v) {
              setState(() {
                _selectedMonth = v ?? 0;
                _applyFilter();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            value: _selectedYear,
            items: yearItems,
            onChanged: (v) {
              setState(() {
                _selectedYear = v ?? 0;
                _applyFilter();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}