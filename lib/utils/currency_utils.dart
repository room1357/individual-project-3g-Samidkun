// File: lib/utils/currency_utils.dart

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

String rp(double amount, BuildContext context) {
  // Ambil service menggunakan Provider melalui context
  final settings = Provider.of<SettingsService>(context, listen: false);
  final symbol = settings.currencySymbol;

  // Menggunakan NumberFormat untuk format yang lebih baik
  final format = NumberFormat.currency(
    locale: symbol == 'Rp' ? 'id_ID' : 'en_US', 
    symbol: '$symbol ',
    decimalDigits: 0,
  );

  return format.format(amount);
}