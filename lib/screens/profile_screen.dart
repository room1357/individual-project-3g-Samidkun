import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _photoC;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _nameC  = TextEditingController(text: user?.name ?? '');
    _phoneC = TextEditingController(text: user?.phone ?? '');
    _photoC = TextEditingController(text: user?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _photoC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameC.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() => _saving = true);
    final ok = AuthService.instance.updateProfile(
      name: _nameC.text.trim(),
      phone: _phoneC.text.trim(),
      photoUrl: _photoC.text.trim(),
    );
    setState(() => _saving = false);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: (u?.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(u!.photoUrl!)
                    : null,
                child: (u?.photoUrl?.isNotEmpty ?? false)
                    ? null
                    : const Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text('Email: ${u?.email ?? "-"}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),

            TextField(
              controller: _nameC,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phoneC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. Telepon (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _photoC,
              decoration: const InputDecoration(
                labelText: 'Photo URL (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
