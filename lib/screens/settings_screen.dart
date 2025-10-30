// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _manualRateC = TextEditingController();
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi textfield sekali dengan rate dari service
    if (!_initDone) {
      final s = context.read<SettingsService>();
      _manualRateC.text = s.rateIdrPerUsd.toStringAsFixed(2);
      _initDone = true;
    }
  }

  @override
  void dispose() {
    _manualRateC.dispose();
    super.dispose();
  }

  Future<void> _saveManualRate() async {
    final raw = _manualRateC.text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null || v <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rate harus angka > 0')),
      );
      return;
    }
    await context.read<SettingsService>().updateRateIdrPerUsd(v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Manual rate disimpan: ${v.toStringAsFixed(2)} IDR/USD')),
    );
  }

  Future<void> _updateRateFromApi() async {
    final ok = await context.read<SettingsService>().fetchRateUsdIdr();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Rate updated dari API' : 'Gagal update rate')),
    );
    if (ok) {
      final s = context.read<SettingsService>();
      _manualRateC.text = s.rateIdrPerUsd.toStringAsFixed(2);
    }
  }

@override
Widget build(BuildContext context) {
  final s = context.watch<SettingsService>();
  final df = DateFormat('dd/MM/yyyy HH:mm');

  return Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      title: const Text('Settings'),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCBF1F5), Color(0xFFD4C1EC)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                value: s.currencyCode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'IDR',
                      child: Text('IDR – Indonesian Rupiah (Rp)')),
                  DropdownMenuItem(
                      value: 'USD', child: Text('USD – US Dollar (\$)')),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  await context.read<SettingsService>().updateCurrency(v);
                },
              ),
            ),

            const SizedBox(height: 28),
            const Text(
              'Exchange Rate (1 USD → IDR)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                    'Current Rate: ${s.rateIdrPerUsd.toStringAsFixed(2)} IDR'),
                subtitle: Text(
                  s.rateUpdatedAt == null
                      ? 'Never updated'
                      : 'Last updated: ${df.format(s.rateUpdatedAt!)}',
                ),
                trailing: s.fetchingRate
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Update from API',
                        onPressed: _updateRateFromApi,
                      ),
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _manualRateC,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Manual rate (IDR per 1 USD)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveManualRate,
              icon: const Icon(Icons.save),
              label: const Text('Save Manual Rate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B5DE5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 28),
            const Divider(),
            const Text(
              'Currency Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Symbol: ${s.currencySymbol}\n'
                'Example format: '
                '${s.currencyCode == "USD" ? "\$12.34" : "Rp 12.345"}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
