import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = AuthService.instance.currentUser ?? '(not signed in)';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: $id'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                AuthService.instance.updateProfile(displayName: 'Demo');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated (demo).')),
                );
              },
              child: const Text('Update Profile (Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
