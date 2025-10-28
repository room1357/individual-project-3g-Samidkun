import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // Untuk navigasi setelah logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = user.name;
      _imagePath = prefs.getString('profile_image_path_${user.id}');
    });
  }

  // [DIUBAH] Fungsi ini sekarang memiliki logika untuk membersihkan cache
  Future<void> _pickAndSaveImage() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _showSnackBar('Failed: You are not logged in.', Colors.red);
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${user.id}.jpg';
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');

    // --- PERBAIKAN UTAMA DI SINI ---
    // 1. Buat ImageProvider dari file yang baru disimpan
    final imageProvider = FileImage(savedImage);
    // 2. Paksa Flutter untuk menghapus cache gambar lama dari path ini
    await imageProvider.evict();
    // --------------------------------

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path_${user.id}', savedImage.path);

    AuthService.instance.updateProfile(name: user.name, photoUrl: savedImage.path);

    // setState tidak lagi diperlukan karena AnimatedBuilder akan handle refresh
    _showSnackBar('Profile photo successfully updated!', Colors.green);
  }

  void _saveProfileChanges() {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      final success = AuthService.instance.updateProfile(name: newName);

      if (success) {
        _showSnackBar('Name successfully updated!', Colors.green);
        FocusScope.of(context).unfocus();
      } else {
        _showSnackBar('Failed to update profile.', Colors.red);
      }
    }
  }

  void _changePassword() {
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('The new password cannot be blank.', Colors.orange);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('The new password and confirmation do not match.', Colors.red);
      return;
    }

    final success = AuthService.instance.changePassword(_newPasswordController.text);
    if (success) {
      _showSnackBar('Password successfully changed!', Colors.green);
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusScope.of(context).unfocus();
    } else {
      _showSnackBar('Failed to change password.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil & Setting'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: AuthService.instance,
        builder: (context, _) {
          final user = AuthService.instance.currentUser;
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          // Ambil path gambar langsung dari AuthService sebagai sumber kebenaran utama
          final imagePath = user.photoUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.pink.shade100,
                          backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                          child: imagePath == null ? Icon(Icons.person, size: 80, color: Colors.pink.shade300) : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: InkWell(
                            onTap: _pickAndSaveImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(label: 'Full Name', icon: Icons.person_outline),
                    validator: (v) => (v == null || v.isEmpty) ? 'The name field cannot be left blank.' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveProfileChanges,
                    style: _buildButtonStyle(Colors.pinkAccent),
                    child: const Text('Save Changes'),
                  ),
                  const Divider(height: 60),
                  const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: _buildInputDecoration(label: 'New Password', icon: Icons.lock_outline),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: _buildInputDecoration(label: 'Confirm New Password', icon: Icons.lock_reset_outlined),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: _buildButtonStyle(Colors.deepPurple.shade400),
                    child: const Text('Change Password'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _buildButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}