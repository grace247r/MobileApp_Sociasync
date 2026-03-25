import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard_page.dart';
import 'package:sociasync_app/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Menghilangkan baris debug di pojok kanan
      theme: ThemeData(
        // Mengatur font Roboto dan warna dasar
        fontFamily: 'Roboto', 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D5093)),
        useMaterial3: true,
      ),
      // UBAH BAGIAN INI:
      home: const SplashScreen(),
    );
  }
}