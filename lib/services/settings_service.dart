import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService() {
    _loadPrefs();
  }

  // ===== STATE =====
  ThemeMode _themeMode = ThemeMode.light;
  String _currencyCode = 'IDR';        // 'IDR' | 'USD'
  double _rateIdrPerUsd = 15500.0;     // 1 USD = X IDR
  DateTime? _rateUpdatedAt;
  bool _fetchingRate = false;

  // ===== GETTERS =====
  ThemeMode get themeMode => _themeMode;
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencyCode == 'USD' ? r'$' : 'Rp';
  double get rateIdrPerUsd => _rateIdrPerUsd;
  DateTime? get rateUpdatedAt => _rateUpdatedAt;
  bool get fetchingRate => _fetchingRate;

  // Konversi dari IDR -> current currency
  double convertFromIdr(double idr) =>
      _currencyCode == 'USD' ? (idr / _rateIdrPerUsd) : idr;

  // ===== MUTATIONS =====
  Future<void> updateThemeMode(ThemeMode m) async {
    _themeMode = m;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> updateCurrency(String code) async {
    final up = code.toUpperCase();
    _currencyCode = (up == 'USD') ? 'USD' : 'IDR';
    await _savePrefs();
    notifyListeners();
  }

  // Manual override rate (opsional)
  Future<void> updateRateIdrPerUsd(double v) async {
    if (v > 0) {
      _rateIdrPerUsd = v;
      _rateUpdatedAt = DateTime.now();
      await _savePrefs();
      notifyListeners();
    }
  }

  /// ====== FETCH RATE DARI API (USD -> IDR) ======
  /// Return true jika sukses update.
  Future<bool> fetchRateUsdIdr() async {
    if (_fetchingRate) return false;
    _fetchingRate = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://api.frankfurter.app/latest?from=USD&to=IDR',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final rates = json['rates'] as Map<String, dynamic>;
        final rate = (rates['IDR'] as num).toDouble();
        if (rate > 0) {
          _rateIdrPerUsd = rate;
          _rateUpdatedAt = DateTime.now();
          await _savePrefs();
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _fetchingRate = false;
      notifyListeners();
    }
  }

  // ===== PERSISTENCE =====
  static const _kTheme = 'theme_mode';
  static const _kCurr = 'currency_code';
  static const _kRate = 'rate_idr_per_usd';
  static const _kWhen = 'rate_updated_at';

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTheme, _themeMode.name);
    await p.setString(_kCurr, _currencyCode);
    await p.setDouble(_kRate, _rateIdrPerUsd);
    if (_rateUpdatedAt != null) {
      await p.setString(_kWhen, _rateUpdatedAt!.toIso8601String());
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == p.getString(_kTheme),
      orElse: () => ThemeMode.light,
    );
    _currencyCode = p.getString(_kCurr) ?? 'IDR';
    _rateIdrPerUsd = p.getDouble(_kRate) ?? 15500.0;
    final when = p.getString(_kWhen);
    if (when != null) _rateUpdatedAt = DateTime.tryParse(when);
    notifyListeners();
  }

  Future<void> init() async {}
}
