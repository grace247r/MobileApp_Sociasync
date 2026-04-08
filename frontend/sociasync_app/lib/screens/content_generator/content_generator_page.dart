import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/content_generator/saved_content_page.dart';
import 'package:sociasync_app/screens/content_generator/content_ideas_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class ContentGeneratorPage extends StatefulWidget {
  const ContentGeneratorPage({super.key});

  @override
  State<ContentGeneratorPage> createState() => _ContentGeneratorPageState();
}

class _ContentGeneratorPageState extends State<ContentGeneratorPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  bool isTikTokSelected = true;
  final Map<String, bool> _toggleStates = {};

  final int _currentIndex = -1;

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatbotPage()));
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menggunakan widget Header yang sudah ada
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // Title & Bookmark Icon
                Padding(
                  padding: const EdgeInsets.only(
                    right: .0,
                  ), // Menyesuaikan agar sejajar dengan icon lonceng
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Content Generator',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SavedContentPage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.bookmark,
                          color: primaryBlue,
                          size: 28,
                        ),
                        splashRadius: 22,
                        tooltip: 'Saved Content',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Platform Selector (TikTok vs Instagram)
                Row(
                  children: [
                    Expanded(
                      child: _buildPlatformBtn('TikTok', isTikTokSelected),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildPlatformBtn('Instagram', !isTikTokSelected),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Topic Input Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Topic of Choice..',
                    hintStyle: TextStyle(color: Color(0XFF1D2F73)),
                    filled: true,
                    fillColor: Color.fromRGBO(220, 227, 255, 0.23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Form Sections
                _buildFormSection('Goal', [
                  'Increase Engagement',
                  'Promote Product',
                  'Brand Awareness',
                  'Drive Sales',
                  'Other..',
                ]),
                const SizedBox(height: 20),
                _buildFormSection('Target Audience', [
                  'Female',
                  'Male',
                  'Teens',
                  'Young Adults',
                  'Food Enthusiasts',
                  'Other..',
                ]),
                const SizedBox(height: 20),
                _buildFormSection('Tone of Voice', [
                  'Friendly',
                  'Professional',
                  'Fun',
                  'Luxury',
                  'Informative',
                  'Other..',
                ]),
                const SizedBox(height: 30),

                // Next Button
                Center(
                  child: SizedBox(
                    width: 170, // Mengunci lebar tombol agar tidak kepanjangan
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ContentIdeasPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB4BCE2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navbar Melayang
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

  // Widget Button TikTok/Instagram
  Widget _buildPlatformBtn(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isTikTokSelected = label == 'TikTok'),
      child: Container(
        height: 33,
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBlue),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Seksi Form (Goal, Target Audience, Tone)
  Widget _buildFormSection(String title, List<String> options) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(220, 227, 255, 0.23),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            bool isOther = option.startsWith('Other');
            final bool isOn = _toggleStates[option] ?? false;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          isOther ? 'Other.. ' : option,
                          style: TextStyle(
                            fontSize: 15,
                            color: primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isOther)
                          Expanded(
                            child: Container(
                              height: 24,
                              margin: const EdgeInsets.only(left: 4, right: 50),
                              decoration: BoxDecoration(
                                color: const Color(0xffba0b1fc),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const TextField(
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFA0B1FC),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Enter',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1D2F73),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Toggle yang bisa diklik
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _toggleStates[option] = !isOn;
                      });
                    },
                    child: _buildCustomToggle(isOn),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Widget Helper untuk Toggle Kustom agar mirip icon di gambar
  Widget _buildCustomToggle(bool isOn) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Efek geser halus
      width: 36,
      height: 20,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryBlue),
        // Opsional: ganti warna background saat ON
        color: isOn ? primaryBlue.withOpacity(0.8) : Colors.transparent,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn ? Colors.white : primaryBlue,
          ),
        ),
      ),
    );
  }
}
