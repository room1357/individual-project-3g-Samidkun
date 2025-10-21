import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';
import 'screens/category_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'models/expense.dart';
import 'services/expense_service.dart';

void main() {
  // Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Bungkus aplikasi dengan Provider agar SettingsService bisa diakses
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil dan "dengarkan" service menggunakan context.watch
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      title: 'Expense Application',
      
      // Mengatur tema berdasarkan state dari service
      themeMode: settings.themeMode,

      // Tema Terang (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),

      // Tema Gelap (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      
      // routes dan onGenerateRoute Anda tetap sama
      routes: {
        '/home': (_) => const HomeScreen(),
        '/expenses': (_) => const ExpenseListScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/categories': (_) => const CategoryScreen(),
        '/stats': (_) => const StatisticsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      onGenerateRoute: (routeSettings) { // ubah nama var 'settings' agar tidak bentrok
        if (routeSettings.name == '/edit') {
          final args = routeSettings.arguments;
          if (args is Expense) {
            return MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: args));
          }
          if (args is String) {
            final e = ExpenseService.instance.getById(args);
            if (e != null) {
              return MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e));
            }
            return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
          }
          return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
        }
        return null;
      },
    );
  }
}