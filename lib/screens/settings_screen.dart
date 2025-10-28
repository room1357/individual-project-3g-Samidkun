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
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Gunakan initialValue (value deprecated di Flutter terbaru)
          DropdownButtonFormField<String>(
            initialValue: s.currencyCode, // 'IDR' atau 'USD'
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'IDR', child: Text('IDR – Indonesian Rupiah (Rp)')),
              DropdownMenuItem(value: 'USD', child: Text('USD – US Dollar (\$)')),
            ],
            onChanged: (v) async {
              if (v == null) return;
              await context.read<SettingsService>().updateCurrency(v);
            },
          ),

          const SizedBox(height: 24),
          const Text('Exchange rate (1 USD → IDR)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Tampilkan info rate aktif
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Rate aktif: ${s.rateIdrPerUsd.toStringAsFixed(2)} IDR'),
            subtitle: Text(
              s.rateUpdatedAt == null
                  ? 'Belum pernah update'
                  : 'Terakhir update: ${df.format(s.rateUpdatedAt!)}',
            ),
            trailing: s.fetchingRate
                ? const SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Update dari API',
                    onPressed: _updateRateFromApi,
                  ),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _manualRateC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Manual rate (IDR per 1 USD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _saveManualRate,
            child: const Text('Simpan manual rate'),
          ),

          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Preview simbol & format'),
            subtitle: Text(
              'Simbol: ${s.currencySymbol}\n'
              'Contoh format: '
              '${s.currencyCode == "USD" ? "\$12.34" : "Rp 12.345"}',
            ),
          ),
        ],
      ),
    );
  }
}
