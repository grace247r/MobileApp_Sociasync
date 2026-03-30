import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/content_generator_page.dart';
import 'package:sociasync_app/screens/dashboard_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
// Import wrapper background yang kita buat sebelumnya
import 'package:sociasync_app/widgets/app_background_wrapper.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color primaryBlue = Color(0xFF1D5093);
  int _currentIndex =
      1; // Sesuaikan index dengan halaman Notification (misal index 1)

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
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
    const notifications = <_NotificationItem>[
      _NotificationItem(
        title: 'Yeayyy!!',
        message: 'You get more 20K views in this week !',
        time: '19.34',
        isHighlighted: true,
      ),
      _NotificationItem(
        title: 'Alert ! New Device Login',
        message: 'System detected new login device Jakarta, Indonesia',
        time: '21.30',
      ),
      _NotificationItem(title: 'Lili', message: 'Hi?', time: '22.16'),
    ];

    // Gunakan AppBackgroundWrapper sebagai pengganti Container image background
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          // KONTEN UTAMA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {
                    // Sudah di page notification, bisa dikosongkan atau pop
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  'Notification',
                  style: TextStyle(
                    fontSize: 20, // Sesuaikan ukuran agar tidak terlalu besar
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    // Tambahkan padding bawah agar tidak mentok navbar
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _NotificationCard(item: notifications[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          // NAVBAR MELAYANG
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
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // Efek Glassmorphism: Putih transparan dengan sedikit blur dari background
        color: Color.fromRGBO(
          78,
          96,
          189,
          0.10,
        ).withOpacity(0.10), // Opacity harus di rentang 0.0..1.0
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D5093), // Gunakan primaryBlue agar serasi
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.isHighlighted = false,
  });

  final String title;
  final String message;
  final String time;
  final bool isHighlighted;
}
