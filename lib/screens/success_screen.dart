// File: lib/screens/success_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen untuk navigasi

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mendorong tombol ke bawah
            crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat elemen melebar
            children: [
              // Kolom untuk konten di atas (agar bisa ditengahkan)
              Column(
                children: [
                  const SizedBox(height: 80),
                  // Ganti path gambar sesuai nama file Anda
                  Image.asset(
                    'assets/images/success_illustration.png',
                    height: 200, // Sesuaikan ukuran gambar
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Sukses Rek!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Berhasil Menambah Pengeluaran.', // Teks yang lebih baik
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),

              // Tombol di bagian bawah
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Sesuaikan dengan tema Anda
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Navigasi kembali ke HomeScreen dan hapus semua halaman di atasnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false, // Predikat ini menghapus semua route sebelumnya
                  );
                },
                child: const Text(
                  'Back To Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}