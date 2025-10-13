import 'dart:async'; // Diperlukan untuk Timer atau Future.delayed
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import halaman login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk navigasi setelah delay
    _navigateToLogin();
  }

  // Fungsi untuk pindah ke halaman Login setelah 10 detik
  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 10), () {
      // Gunakan pushReplacement agar pengguna tidak bisa kembali ke splash screen
      // dengan menekan tombol back.
      if (mounted) {
        // Cek apakah widget masih ada di tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita gunakan widget Center untuk menempatkan gambar tepat di tengah
      body: Center(
        child: Image.asset('assets/images/group1.png'),
      ),
    );
  }
}
