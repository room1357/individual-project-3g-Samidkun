import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false,
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dark Mode Coming Soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Aplikasi Pengeluaran',
                applicationVersion: '1.0.0',
                children: [const Text('Dibuat untuk latihan navigasi & ListView.')],
              );
            },
          ),
        ],
      ),
    );
  }
}
