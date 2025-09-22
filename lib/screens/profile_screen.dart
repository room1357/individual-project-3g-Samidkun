import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            const Text('Nama Pengguna', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('user@email.com', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
