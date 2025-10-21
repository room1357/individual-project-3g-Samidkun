import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import 'export_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar UI otomatis update saat ada perubahan
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          body: ListView(
            children: [
              const SizedBox(height: 20),
              _buildSectionTitle('Pengaturan Umum'),
              
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Tema Aplikasi'),
                subtitle: Text(_themeModeToString(settings.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemePicker(context, settings),
              ),
              
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Mata Uang'),
                subtitle: Text(_currencyToString(settings.currencySymbol)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCurrencyPicker(context, settings),
              ),

              const Divider(),
              _buildSectionTitle('Data Aplikasi'),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('Export Data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Terang'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (val) {
                settings.updateThemeMode(val);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Gelap'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (val) {
                settings.updateThemeMode(val);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Mengikuti Sistem'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (val) {
                settings.updateThemeMode(val);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Mata Uang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Rupiah (Rp)'),
              value: 'Rp',
              groupValue: settings.currencySymbol,
              onChanged: (val) {
                settings.updateCurrency(val);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('US Dollar (\$)'),
              value: '\$',
              groupValue: settings.currencySymbol,
              onChanged: (val) {
                settings.updateCurrency(val);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    if (mode == ThemeMode.light) return 'Terang';
    if (mode == ThemeMode.dark) return 'Gelap';
    return 'Mengikuti Sistem';
  }

  String _currencyToString(String symbol) {
    if (symbol == 'Rp') return 'Rupiah (Rp)';
    if (symbol == '\$') return 'US Dollar (\$)';
    return 'Tidak Diketahui';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}