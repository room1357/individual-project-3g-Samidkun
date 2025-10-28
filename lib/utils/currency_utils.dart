import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

String rp(double amountIdr, BuildContext context, {bool withSymbol = true}) {
  final s = context.watch<SettingsService>();
  final isUsd = s.currencyCode == 'USD';

  final value = isUsd ? (amountIdr / s.rateIdrPerUsd) : amountIdr;
  final locale = isUsd ? 'en_US' : 'id_ID';
  final symbol = withSymbol ? s.currencySymbol : '';

  final fmt = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: isUsd ? 2 : 0,
  );
  return fmt.format(value);
}
