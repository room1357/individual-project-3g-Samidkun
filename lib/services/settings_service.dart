import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService() {
    loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol = 'Rp';

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeString = prefs.getString('themeMode') ?? 'system';
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    _currencySymbol = prefs.getString('currencySymbol') ?? 'Rp';
    
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String themeString = 'system';
    if (newThemeMode == ThemeMode.light) themeString = 'light';
    if (newThemeMode == ThemeMode.dark) themeString = 'dark';
    await prefs.setString('themeMode', themeString);
  }

  Future<void> updateCurrency(String? newCurrency) async {
    if (newCurrency == null || newCurrency == _currencySymbol) return;

    _currencySymbol = newCurrency;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencySymbol', newCurrency);
  }
}