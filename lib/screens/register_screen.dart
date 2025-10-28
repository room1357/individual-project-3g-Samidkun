// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_directory_service.dart'; // <-- penting
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  final _usernameC = TextEditingController(); // <-- baru

  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _usernameC.dispose(); // <-- baru
    super.dispose();
  }

  String _sanitizeUsername(String raw) {
    // ke lowercase, buang @, spasi → -, sisakan huruf/angka/._-
    final s = raw.trim().toLowerCase().replaceAll('@', '').replaceAll(' ', '-');
    final cleaned = s.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    return cleaned;
  }

  Future<void> _doRegister() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final pass  = _passC.text;

    // username dari input; kalau kosong → pakai prefix email
    String username = _sanitizeUsername(
      _usernameC.text.isEmpty ? email.split('@').first : _usernameC.text,
    );

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, email, dan password wajib diisi')),
      );
      return;
    }
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak boleh kosong')),
      );
      return;
    }

    // Cek duplikasi username di direktori lokal
    final exists = UserDirectoryService.instance.findByUsername(username) != null;
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username @$username sudah dipakai, pilih yang lain.')),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await AuthService.instance.register(email, pass, name);

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sudah terpakai')),
      );
      return;
    }

    // Registrasi sukses → ambil user aktif lalu daftarkan ke direktori
    final u = AuthService.instance.currentUser!;
    // kalau AuthService kamu belum menyimpan "username", direktori inilah sumber kebenaran
    UserDirectoryService.instance.upsert(
      id: u.id,
      username: username,
      name: u.name ?? name,
      email: u.email,
    );

    // lanjut ke home
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'List',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),

            // Name
            TextField(
              controller: _nameC,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Username (baru)
            TextField(
              controller: _usernameC,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Email
            TextField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Password
            TextField(
              controller: _passC,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 216, 0, 198),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _loading ? null : _doRegister,
              child: _loading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
