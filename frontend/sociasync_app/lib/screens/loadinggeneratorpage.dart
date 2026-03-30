import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/generator_loading.dart';

class LoadingGeneratorPage extends StatefulWidget {
  const LoadingGeneratorPage({super.key});

  @override
  State<LoadingGeneratorPage> createState() => _LoadingGeneratorPageState();
}

class _LoadingGeneratorPageState extends State<LoadingGeneratorPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  @override
  void initState() {
    super.initState();
    // Simulasi loading 3 detik
    _finishLoading();
  }

  void _finishLoading() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Setelah loading selesai, balik ke halaman sebelumnya atau ke ResultPage
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          // BAGIAN 1 & 2: Konten Utama (Header + Kotak Loading)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WIDGET ATAS: DashboardHeader
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {},
                ),

                // Spacer agar Kotak Loading berada di tengah layar secara vertikal
                const Spacer(),

                // WIDGET TENGAH: Loading Generator
                SizedBox(
                  height: 340,
                  child: Center(child: GeneratorLoadingWidget()),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Generating Content...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D5093),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Spacer bawah agar proporsional
                const Spacer(flex: 2),
              ],
            ),
          ),

          // BAGIAN 3: WIDGET NAVBAR (Melayang di bawah)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: 0, // Tetap di index Home/Generator
              backgroundColor: primaryBlue,
              onTap: (index) {},
            ),
          ),
        ],
      ),
    );
  }
}
