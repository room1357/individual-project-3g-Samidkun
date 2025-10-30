// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'category_screen.dart';
import 'expense_list_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'login_screen.dart';
import 'export_screen.dart';

import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../utils/currency_utils.dart';
import '../utils/category_style.dart';
import 'add_income_screen.dart';
import 'balance_screen.dart';
import 'share_expenses_screen.dart';
import 'shared_from_others_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _profileImagePath;

  // Widget untuk setiap tab (sekarang 5)
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardContent(), // 0
    AddIncomeScreen(), // 1
    ExpenseListScreen(), // 2
    CategoryScreen(), // 3
    StatisticsScreen(), // 4
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    AuthService.instance.addListener(_loadProfileImage);

    // Muat data expenses & incomes di awal
    _bootstrapData();
  }

  Future<void> _bootstrapData() async {
    await Future.wait([
      ExpenseService.instance.loadInitialData(),
      IncomeService.instance.loadInitialData(),
    ]);
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

Widget _buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.purpleAccent),
    title: Text(
      title,
      style: GoogleFonts.poppins(fontSize: 15),
    ),
    onTap: onTap,
  );
}
BottomNavigationBarItem _buildNavItem(String label, dynamic icon) {
  bool isSvg = icon is String;
  return BottomNavigationBarItem(
    icon: isSvg
        ? SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          )
        : Icon(icon),
    activeIcon: isSvg
        ? SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
          )
        : Icon(icon, color: Colors.pinkAccent),
    label: label,
  );
}


  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Add Income';
      case 2:
        return 'Expense List';
      case 3:
        return 'Manage Categories';
      case 4:
        return 'Statistics';
      default:
        return 'Expense Manager';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Colors.pinkAccent;
    const Color inactiveColor = Colors.grey;
    final user = AuthService.instance.currentUser;

    return Scaffold(
  extendBodyBehindAppBar: true,
  backgroundColor: Colors.transparent,
  appBar: AppBar(
    title: Text(
      _getAppBarTitle(_selectedIndex),
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.black87,
      ),
    ),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.account_balance_wallet_outlined,
            color: Colors.purpleAccent),
      ),
    ],
  ),
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            user?.name ?? 'Username',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          accountEmail: Text(
            user?.email ?? 'email@pengguna.com',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: _profileImagePath != null
                ? FileImage(File(_profileImagePath!))
                : null,
            child: _profileImagePath == null
                ? Icon(Icons.person, size: 45, color: Colors.pink.shade300)
                : null,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8BD0), Color(0xFFB388EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        _buildDrawerTile(Icons.person_outline, 'Profile', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }),
        _buildDrawerTile(Icons.settings_outlined, 'Settings', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }),
        _buildDrawerTile(Icons.account_balance_wallet_outlined, 'Balance', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BalanceScreen()));
        }),
        _buildDrawerTile(Icons.share_outlined, 'Share Expense', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ShareExpensesScreen()));
        }),
        _buildDrawerTile(Icons.inbox_outlined, 'Shared from others', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SharedFromOthersScreen()));
        }),
        const Divider(),
        _buildDrawerTile(Icons.logout, 'Logout', () {
          AuthService.instance.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }),
      ],
    ),
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
    type: BottomNavigationBarType.fixed,
    selectedFontSize: 12,
    unselectedFontSize: 12,
    selectedItemColor: Colors.pinkAccent,
    unselectedItemColor: Colors.grey.shade500,
    backgroundColor: Colors.white,
    elevation: 8,
    items: [
      _buildNavItem('Home', 'assets/icons/home.svg'),
      _buildNavItem('Income', Icons.savings),
      _buildNavItem('Expenses', 'assets/icons/expenses.svg'),
      _buildNavItem('Categories', 'assets/icons/category.svg'),
      _buildNavItem('Stats', 'assets/icons/stats.svg'),
    ],
  ),
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFCBF1F5), // Biru muda
          Color(0xFFD4C1EC), // Ungu muda
        ],
      ),
    ),
    child: SafeArea(
      child: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    ),
  ),
);

  }
}

// ================= Dashboard =================

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final expSvc = ExpenseService.instance;
    final incSvc = IncomeService.instance;

    return AnimatedBuilder(
      // Rebuild bila income ATAU expense berubah
      animation: Listenable.merge([expSvc, incSvc]),
      builder: (context, _) {
        final totalExpense = expSvc.totalAll;
        final totalIncome = incSvc.totalAll;
        final balance = totalIncome - totalExpense;

        final recentExpenses = expSvc.expenses.take(5).toList();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 20),
              _buildBalanceCard(context, balance, totalIncome, totalExpense),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExportScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade50,
                  foregroundColor: Colors.pinkAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Export'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Current Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (recentExpenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text('No expenses yet.')),
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

  // ---------- UI helpers ----------

  Widget _buildBalanceCard(
  BuildContext context,
  double balance,
  double totalIncome,
  double totalExpense,
) {
  final positive = balance >= 0;

  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: positive
            ? [Colors.teal.shade400, Colors.teal.shade600]
            : [Colors.red.shade400, Colors.red.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.account_balance_wallet_outlined,
                color: Colors.white70, size: 20),
            SizedBox(width: 8),
            Text('Balance',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          rp(balance, context),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _miniPill(
              icon: Icons.south_west,
              label: '+ ${rp(totalIncome, context)}',
              color: Colors.greenAccent,
            ),
            _miniPill(
              icon: Icons.north_east,
              label: '- ${rp(totalExpense, context)}',
              color: Colors.redAccent,
            ),
          ],
        ),
      ],
    ),
  );
}

  void _showExpenseDetailDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(expense.title),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('Amount:', rp(expense.amount, context)),
                _buildDetailRow('Category:', expense.category),
                _buildDetailRow('Date:', expense.formattedDate),
                if (expense.description.isNotEmpty)
                  _buildDetailRow('Description:', expense.description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
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
            TextSpan(
                text: '$label ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
        onTap: () => _showExpenseDetailDialog(context, expense),
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
                    Text(expense.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _miniPill({
  required IconData icon,
  required String label,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15), // efek soft dari warna
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}


}
