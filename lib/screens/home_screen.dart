import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan semua import screen Anda sudah benar
import 'category_screen.dart';
import 'expense_list_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'login_screen.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/category_style.dart';
import 'export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _profileImagePath;

  // [DIUBAH] Daftar widget sekarang hanya 4
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardContent(),
    ExpenseListScreen(),
    CategoryScreen(),
    StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    AuthService.instance.addListener(_loadProfileImage);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_loadProfileImage);
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      if (mounted) setState(() => _profileImagePath = user.photoUrl);
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _profileImagePath = prefs.getString('profile_image_path_${user.id}');
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // [DIUBAH] Judul AppBar disesuaikan untuk 4 item
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Daftar Pengeluaran';
      case 2: return 'Kelola Kategori';
      case 3: return 'Statistik';
      default: return 'Expense Manager';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Colors.pinkAccent;
    const Color inactiveColor = Colors.grey;
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.name ?? 'Nama Pengguna',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? 'email@pengguna.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                child: _profileImagePath == null ? Icon(Icons.person, size: 45, color: Colors.pink.shade300) : null,
              ),
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // [DIUBAH] Langsung navigasi ke SettingsScreen
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                AuthService.instance.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: activeColor,
        unselectedItemColor: inactiveColor,
        // [DIUBAH] Item navigasi sekarang hanya 4
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/home.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(inactiveColor, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/icons/home.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/expenses.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(inactiveColor, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/icons/expenses.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn)),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/category.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(inactiveColor, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/icons/category.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn)),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/stats.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(inactiveColor, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/icons/stats.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn)),
            label: 'Stats',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}

// ... Sisa kode (class DashboardContent dan helper-helpernya) tidak berubah ...
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    return AnimatedBuilder(
      animation: svc,
      builder: (context, _) {
        final totalExpense = svc.totalAll;
        final recentExpenses = (svc.expenses).take(5).toList();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 20),
              _buildTotalExpenseCard(context, totalExpense),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade50,
                  foregroundColor: Colors.pinkAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Export'),
              ),
              const SizedBox(height: 30),
              const Text('Pengeluaran Saat Ini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (recentExpenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text('Belum ada pengeluaran.')),
                )
              else
                ListView.builder(
                  itemCount: recentExpenses.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final expense = recentExpenses[index];
                    return _buildExpenseListItem(context, expense);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showExpenseDetailDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(expense.title),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('Jumlah:', rp(expense.amount, context)),
                _buildDetailRow('Kategori:', expense.category),
                _buildDetailRow('Tanggal:', expense.formattedDate),
                if (expense.description.isNotEmpty)
                  _buildDetailRow('Deskripsi:', expense.description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpenseListItem(BuildContext context, Expense expense) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showExpenseDetailDialog(context, expense);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              categoryAvatar(expense.category, size: 45),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.category} • ${expense.formattedDate}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '- ${rp(expense.amount, context)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalExpenseCard(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/edit_note.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                'Total Expense',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rp(total, context),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}