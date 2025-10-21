import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller & State dari kode lama Anda
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  bool _loading = false;
  // State _isPasswordVisible tidak lagi dibutuhkan karena desain baru tidak ada ikon mata

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  // Fungsi _doLogin dari kode lama Anda (tidak ada yang diubah)
  Future<void> _doLogin() async {
    setState(() => _loading = true);

    final ok = await AuthService.instance.login(
      _emailC.text.trim(),
      _passC.text,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau password salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // [UI-UPDATE] Menggunakan Scaffold dengan background putih polos
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Jarak dari atas layar
            const SizedBox(height: 100),

            // [UI-UPDATE] Judul "Login" di dalam body
            const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),

            // [UI-UPDATE] TextField Email disederhanakan (tanpa ikon)
            TextField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // [UI-UPDATE] TextField Password disederhanakan (tanpa ikon mata)
            TextField(
              controller: _passC,
              obscureText: true, // Kembali ke obscureText standar
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // [UI-UPDATE] Tombol diubah menjadi ElevatedButton dengan warna pink
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 237, 0, 217), // Warna utama baru
                foregroundColor: Colors.white, // Warna teks
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _loading ? null : _doLogin,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),

            // [UI-UPDATE] Tombol link dengan warna pink
            TextButton(
              onPressed: () { /* TODO: Fitur Lupa Kata Sandi */ },
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 255)),
              ),
            ),
            const SizedBox(height: 24),

            // [UI-UPDATE] Link Sign Up dengan style baru
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum Punya Akun?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Daftar Sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 0, 191),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}