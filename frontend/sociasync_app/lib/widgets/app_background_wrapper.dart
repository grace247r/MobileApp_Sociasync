import 'package:flutter/material.dart';

class AppBackgroundWrapper extends StatelessWidget {
  // 'child' adalah konten halaman (Scaffold dsb) yang akan dibungkus
  final Widget child;

  const AppBackgroundWrapper({super.key, required this.child});

  // Warna gradasi dari Figma kamu (324AB3)
  final Color baseColor = const Color(0xFF324AB3);

  @override
  Widget build(BuildContext context) {
    // Kita pakai LayoutBuilder agar tahu ukuran pasti layar (lebar/tinggi)
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Scaffold(
          // Memastikan background berwarna putih dasar
          backgroundColor: Colors.white,
          // Memungkinkan konten ekstens di belakang navbar
          extendBody: true,
          // Menggunakan Stack untuk menumpuk background dan konten
          body: Stack(
            children: [
              // --- LAPISAN 1: Lingkaran-Lingkaran Background ---

              // Lingkaran Besar Kiri Atas
              _buildBlurredCircle(
                size: screenWidth * 0.7, // 70% lebar layar
                top: -screenWidth * 0.2, // Menjorok ke luar atas
                left: -screenWidth * 0.1, // Menjorok ke luar kiri
              ),

              // Lingkaran Besar Kanan Atas
              _buildBlurredCircle(
                size: screenWidth * 0.6,
                top: screenHeight * 0.1, // Jarak dari atas
                right: -screenWidth * 0.1, // Menjorok ke luar kanan
              ),

              // Lingkaran Kecil Kiri Tengah (Ketinggian Weekly Chart)
              _buildBlurredCircle(
                size: 150, // Ukuran tetap
                top: screenHeight * 0.45,
                left: -40, // Menjorok sedikit ke kiri
              ),

              // Lingkaran Kecil Kanan Tengah
              _buildBlurredCircle(
                size: 80,
                top: screenHeight * 0.48,
                right: screenWidth * 0.15, // Beri jarak dari kanan
              ),

              // Lingkaran Besar Kanan Bawah (Di area Post)
              _buildBlurredCircle(
                size: screenWidth * 0.4,
                bottom: screenHeight * 0.25, // Jarak dari bawah
                right: -30,
              ),

              // Lingkaran Kecil Kiri Bawah (Dekat tombol)
              _buildBlurredCircle(
                size: 110,
                bottom: screenHeight * 0.15,
                left: screenWidth * 0.05,
              ),

              // --- LAPISAN 2: Konten Halaman Asli ---
              // Kita bungkus child dengan SafeArea agar konten tidak kena notch
              SafeArea(child: child),
            ],
          ),
        );
      },
    );
  }

  // Helper widget untuk membuat lingkaran dengan gradasi dan blur
  Widget _buildBlurredCircle({
    required double size,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Menggunakan gradasi Radial (Melingkar)
          gradient: RadialGradient(
            colors: [
              // Warna dasar dengan opacity penuh (sesuai Figma stops 0%)
              baseColor.withOpacity(0.3), // Sesuaikan opacity untuk efek 'soft'
              // Warna dasar dengan opacity 0 (sesuai Figma stops 100%)
              baseColor.withOpacity(0.0),
            ],
            // Mengatur stop gradasi agar bagian tengah lebih solid
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }
}
