import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/content generator/content_generator_page.dart';
import 'package:sociasync_app/screens/analytics/monthly_summary_page.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 0; // Untuk melacak posisi Navbar

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ContentGeneratorPage()),
      );
      return;
    }

    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Halaman profil belum tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan AppBackgroundWrapper sebagai pondasi utama
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          // LAPISAN 1: Konten Utama (Header, Stats, Chart, dsb)
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // Stats Grid
                // --- STATS GRID DENGAN BACKGROUND WADAH ---
                Container(
                  padding: const EdgeInsets.all(
                    12.0,
                  ), // Jarak antara wadah biru ke kartu stats
                  decoration: BoxDecoration(
                    // Warna biru transparan untuk wadah (mirip di gambar)
                    color: primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10, // Jarak horizontal antar kartu
                    mainAxisSpacing: 10, // Jarak vertikal antar kartu
                    childAspectRatio: 1.8,
                    children: [
                      _buildStatCard('4.8%', 'Engagement'),
                      _buildStatCard('45.7 K', 'Reach'),
                      _buildStatCard('12.9 K', 'Followers'),
                      _buildStatCard('24', 'Post'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Weekly Chart Section
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MonthlySummaryPage(),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Chart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // Menggunakan opacity rendah agar background gradasi tetap tembus pandang
                          color: primaryBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.1),
                          ),
                        ),
                        child: const Center(
                          child: Text("Line Chart Placeholder"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Best Performing Post Section
                const Text(
                  'Best Performing Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPostItem('assets/post1.png'),
                      _buildPostItem('assets/post2.png'),
                      _buildPostItem('assets/post3.png'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Generate Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContentGeneratorPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '+ Generate',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                // Tambahkan SizedBox besar di bawah agar konten tidak tertutup Navbar melayang
                const SizedBox(height: 100),
              ],
            ),
          ),

          // LAPISAN 2: Navbar Melayang (Floating)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: _currentIndex,
              backgroundColor: primaryBlue,
              onTap: _onNavbarTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Sedikit transparan agar estetik
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: primaryBlue,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(String imagePath) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(child: Icon(Icons.image, color: Colors.white)),
    );
  }
}
