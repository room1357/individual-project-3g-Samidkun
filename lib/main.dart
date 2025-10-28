// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/settings_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';
import 'screens/category_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'models/expense.dart';
import 'services/expense_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Buat satu instance SettingsService, inisialisasi dulu (load currency/rate)
  final settings = SettingsService();
  await settings.init();

  runApp(
    ChangeNotifierProvider<SettingsService>.value(
      value: settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan SettingsService (currency/rate)
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      title: 'Expense Application',
      debugShowCheckedModeBanner: false,

      // Tema (pakai sistem atau sesuaikan kalau nanti ada toggle)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.pinkAccent,
      //     brightness: Brightness.dark,
      //   ),
      //   useMaterial3: true,
      // ),
      themeMode: ThemeMode.system,

      // rebuild otomatis saat settings berubah (karena kita pakai watch di atas)
      home: const SplashScreen(),

      routes: {
        '/home': (_) => const HomeScreen(),
        '/expenses': (_) => const ExpenseListScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/categories': (_) => const CategoryScreen(),
        '/stats': (_) => const StatisticsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },

      onGenerateRoute: (routeSettings) {
        if (routeSettings.name == '/edit') {
          final args = routeSettings.arguments;
          if (args is Expense) {
            return MaterialPageRoute(
              builder: (_) => EditExpenseScreen(expense: args),
            );
          }
          if (args is String) {
            final e = ExpenseService.instance.getById(args);
            if (e != null) {
              return MaterialPageRoute(
                builder: (_) => EditExpenseScreen(expense: e),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const ExpenseListScreen(),
            );
          }
          return MaterialPageRoute(
            builder: (_) => const ExpenseListScreen(),
          );
        }
        return null;
      },
    );
  }
}
