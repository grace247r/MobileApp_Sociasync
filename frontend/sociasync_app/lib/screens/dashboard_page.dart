import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/navbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: const Color(0xFF1D5093),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentNavIndex = 0;
  final Color primaryBlue = const Color(0xFF1D5093);
  int _currentIndex = 0; // Untuk melacak posisi Navbar

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

              // Weekly Chart
              Text(
                'Weekly Chart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                  decoration: TextDecoration.underline,
                ),
                const SizedBox(height: 15),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // Menggunakan opacity rendah agar background gradasi tetap tembus pandang
                    color: primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryBlue.withOpacity(0.1)),
                  ),
                  child: const Center(child: Text("Line Chart Placeholder")),
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
              ),
              const SizedBox(height: 20),
            ],
          ),

      bottomNavigationBar: Navbar(
        selectedIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          print("Pindah ke halaman index: $index");
        },
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
      ),
      child: const Center(child: Icon(Icons.image, color: Colors.white)),
    );
  }
}
