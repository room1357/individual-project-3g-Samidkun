// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login_screen.dart'; // Import login screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  bool _isLastPage = false;

  Future<void> _onboardingFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView untuk halaman yang bisa di-swipe
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == 2;
              });
            },
            children: const [
              // Halaman 1
              OnboardingPageContent(
                image: 'assets/images/onboarding1.png', // GANTI DENGAN GAMBAR ANDA
                iconData: Icons.monetization_on,        // GANTI DENGAN IKON ANDA
                title: 'Track Every Rupiah',
                description: 'Easily record all your income and expenses in one place.',
              ),
              // Halaman 2
              OnboardingPageContent(
                image: 'assets/images/onboarding2.png', // GANTI DENGAN GAMBAR ANDA
                iconData: Icons.category,                // GANTI DENGAN IKON ANDA
                title: 'Clear Categories',
                description: 'Group your transactions into categories for better analysis.',
              ),
              // Halaman 3
              OnboardingPageContent(
                image: 'assets/images/onboarding3.png', // GANTI DENGAN GAMBAR ANDA
                iconData: Icons.auto_graph,              // GANTI DENGAN IKON ANDA
                title: 'Understand Your Finances',
                description: 'Check out visual reports to help you make smarter financial decisions.',
              ),
            ],
          ),

          // Indikator titik-titik dan tombol di bagian bawah
          Container(
            alignment: const Alignment(0, 0.9), // Sedikit naikkan posisi
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol "Skip"
                TextButton(
                  onPressed: () => _controller.jumpToPage(2),
                  child: const Text('SKIP'),
                ),

                // Indikator titik-titik
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const WormEffect(
                    spacing: 16,
                    dotColor: Colors.black26,
                    activeDotColor: Colors.deepPurple,
                  ),
                ),

                // Tombol "Next" atau "Done"
                _isLastPage
                    ? TextButton(
                        onPressed: () async {
                          await _onboardingFinished();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        },
                        child: const Text('DONE'),
                      )
                    : TextButton(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                        child: const Text('NEXT'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget konten halaman yang sudah disesuaikan dengan desain Figma
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.image,
    required this.iconData,
    required this.title,
    required this.description,
  });

  final String image;
  final IconData iconData; // Parameter untuk ikon
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi utama
          Image.asset(
            image,
            height: MediaQuery.of(context).size.height * 0.35, // Atur tinggi gambar
          ),
          const SizedBox(height: 60), // Jarak antara gambar dan ikon

          // Ikon dalam lingkaran ungu
          CircleAvatar(
            radius: 50, // Ukuran lingkaran
            backgroundColor: Colors.deepPurple.shade100, // Warna latar lingkaran
            child: Icon(
              iconData,
              size: 50, // Ukuran ikon
              color: Colors.deepPurple, // Warna ikon
            ),
          ),
          const SizedBox(height: 40), // Jarak antara ikon dan judul

          // Judul utama (Dummy Teks baris pertama)
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16), // Jarak antara judul dan deskripsi

          // Deskripsi (Dummy Teks baris kedua dan ketiga)
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}