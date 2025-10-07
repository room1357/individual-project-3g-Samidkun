import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';
import 'screens/category_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';

import 'services/expense_service.dart';
import 'models/expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      debugShowCheckedModeBanner: false,
      // Route statis yang tidak butuh argumen
      routes: {
        '/home': (_) => const HomeScreen(),
        '/expenses': (_) => const ExpenseListScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/categories': (_) => const CategoryScreen(),
        '/stats': (_) => const StatisticsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },

      // Route dinamis: /edit
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final args = settings.arguments;

          // mode 1: langsung kirim instance Expense
          if (args is Expense) {
            return MaterialPageRoute(
              builder: (_) => EditExpenseScreen(expense: args),
            );
          }

          // mode 2: kirim String expenseId, ambil dari service
          if (args is String) {
            final e = ExpenseService.instance.getById(args);
            if (e != null) {
              return MaterialPageRoute(
                builder: (_) => EditExpenseScreen(expense: e),
              );
            }
            // kalau id tidak ketemu, balik ke daftar
            return MaterialPageRoute(
              builder: (_) => const ExpenseListScreen(),
            );
          }

          // fallback bila argumen tidak valid
          return MaterialPageRoute(
            builder: (_) => const ExpenseListScreen(),
          );
        }

        // unknown route -> home
        return null;
      },
    );
  }
}
