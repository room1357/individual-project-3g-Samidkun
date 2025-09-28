import 'package:flutter/material.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/category_screen.dart';

// Service (load data awal)
import 'services/expense_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ExpenseService _service = ExpenseService.instance;

  @override
  void initState() {
    super.initState();
    _service.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Halaman pertama
      home: const LoginScreen(),

      // Named routes (dipakai tombol/menu di app)
      routes: {
        '/home': (_) => const HomeScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/stats': (_) => const StatisticsScreen(),
        '/categories': (_) => const CategoryScreen(),
      },

      // Route dinamis untuk Edit (butuh argumen id)
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => EditExpenseScreen(expenseId: id),
          );
        }
        return null;
      },
    );
  }
}
