import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/splash_screen.dart';

// Import sub-halaman
import 'package:sociasync_app/screens/profile/account_page.dart';
import 'package:sociasync_app/screens/profile/privacy_page.dart';
import 'package:sociasync_app/screens/profile/notification_page.dart';
import 'package:sociasync_app/screens/profile/help_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final Color primaryBlue = const Color(0xFF1D5093);

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // KUNCI UTAMA: Membiarkan body naik melewati area atas
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Column(
              children: [
                // 1. HEADER (BIRU MENTOK KE ATAS)
                _buildMentokHeader(context),

                // 2. KONTEN MENU
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('General'),
                        _buildSettingsGroup([
                          _buildSettingsTile(
                            'Account',
                            Icons.person_outline,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountPage(),
                              ),
                            ),
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            'Privacy',
                            Icons.lock_outline,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPage(),
                              ),
                            ),
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            'Notification',
                            Icons.notifications_none,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationPage(),
                              ),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 25),
                        _buildSectionLabel('Helpdesk'),
                        _buildSettingsGroup([
                          _buildSettingsTile(
                            'Help',
                            Icons.help_outline,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpPage(),
                              ),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 25),
                        _buildSectionLabel('Connect'),
                        _buildSettingsGroup([
                          _buildConnectTile('TikTok'),
                          _buildDivider(),
                          _buildConnectTile('Instagram'),
                        ]),

                        const SizedBox(height: 25),
                        _buildSectionLabel('Danger Zone'),
                        _buildSettingsGroup([
                          _buildSettingsTile(
                            'Log Out',
                            Icons.logout,
                            textColor: Colors.red.shade400,
                            onTap: () => _showLogOutDialog(context),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // App Navbar Melayang
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: 3,
                backgroundColor: primaryBlue,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  }
                  if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarWeekPage(),
                      ),
                    );
                  }
                  if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatbotPage()),
                    );
                  }
                  if (index == 3) {
                    // On profile page, stay on profile (do nothing)
                    return;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentokHeader(BuildContext context) {
    // Mengambil tinggi Status Bar agar konten teks tidak terlalu ke atas
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 280 + statusBarHeight, // Tinggi dinamis mengikuti layar
      child: Stack(
        children: [
          // BACKGROUND BIRU GRADASI (Mulai dari koordinat 0)
          ClipPath(
            clipper: LonjongClipper(),
            child: Container(
              width: double.infinity,
              height: 220 + statusBarHeight, // Biru mentok ke paling atas
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF294D9B), Color(0xFF3895FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Tombol Back & Title (Diberi margin atas sebesar tinggi Status Bar)
          Positioned(
            top: statusBarHeight + 10,
            left: 10,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Foto Profil melayang
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: const AssetImage('assets/logo.png'),
                    backgroundColor: const Color(0xFFDDE8F5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rina',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: primaryBlue.withOpacity(0.5),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Divider(
    height: 1,
    color: primaryBlue.withOpacity(0.05),
    indent: 55,
    endIndent: 20,
  );

  Widget _buildSettingsTile(
    String title,
    IconData icon, {
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? primaryBlue, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildConnectTile(String platform) {
    return ListTile(
      leading: const Icon(Icons.link, color: Color(0xFF1D5093), size: 22),
      title: Text(
        platform,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Connect',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// CLIPPER LONJONG
class LonjongClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 50,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
