import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/inbox/inbox_page.dart';

class SavedContentPage extends StatefulWidget {
  const SavedContentPage({super.key});

  @override
  State<SavedContentPage> createState() => _SavedContentPageState();
}

class _SavedContentPageState extends State<SavedContentPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 1; // Index untuk navbar (History/Saved)

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const InboxPage()));
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
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header tetap pakai widget yang sudah ada
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
                const SizedBox(height: 20),

                // Title Section dengan Back Button & Date Filter
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: primaryBlue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Saved Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const Spacer(),
                    // Date Filter Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'Jan - Jul 2026',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: primaryBlue.withOpacity(0.4)),
                    filled: true,
                    fillColor: const Color(
                      0xFFDCE3FF,
                    ).withOpacity(0.23), // Biru muda transparan
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Filter Buttons (Sort by size/date)
                Row(
                  children: [
                    _buildFilterChip('Sort by size', true),
                    const SizedBox(width: 10),
                    _buildFilterChip('Sort by date', true),
                  ],
                ),
                const SizedBox(height: 20),

                // Grid Container (Wadah Biru Transparan)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE3FF).withOpacity(0.23),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: 12, // Lebih banyak item agar panjang ke bawah
                    itemBuilder: (context, index) {
                      return _buildContentItem();
                    },
                  ),
                ),
                const SizedBox(height: 100), // Spasi Navbar
              ],
            ),
          ),

          // Navbar Melayang (Gunakan index 1 untuk History/Saved)
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

  // Widget Helper untuk Filter Chip
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Widget Helper untuk Item di Grid
  Widget _buildContentItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade300,
        image: const DecorationImage(
          image: NetworkImage(
            'https://via.placeholder.com/150',
          ), // Ganti image asset kamu
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Date Badge (15 MAR) di pojok kiri atas
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '15\nMAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Text Overlay "what i eat"
          const Center(
            child: Text(
              'what i eat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
