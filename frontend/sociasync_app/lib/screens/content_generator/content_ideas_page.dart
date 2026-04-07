import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/content_generator/script_result_page.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';

import 'package:sociasync_app/screens/inbox/inbox_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class ContentIdeasPage extends StatefulWidget {
  const ContentIdeasPage({super.key});

  @override
  State<ContentIdeasPage> createState() => _ContentIdeasPageState();
}

class _ContentIdeasPageState extends State<ContentIdeasPage> {
  final int _currentIndex = -1;
  final Color primaryBlue = const Color(0xFF1D5093);

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InboxPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
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
                // HEADER
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {},
                ),

                const SizedBox(height: 20),

                const Text(
                  'Content Generator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Content Ideas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D5093),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔥 CONTENT IDEAS ONLY
                ContentIdeaCard(
                  title: 'Street Food Hook',
                  badgeText: 'Content Opportunity',
                  emoji: '💡',
                  description:
                      'Street food videos under 45 seconds are generating higher watch time. Try a quick first bite reaction.',
                  primaryColor: primaryBlue,
                ),

                const SizedBox(height: 15),

                ContentIdeaCard(
                  title: 'Engagement Booster',
                  badgeText: 'Comment Driver',
                  emoji: '🔥',
                  description:
                      'Spicy challenge content drives more comments. Try level 1–5 spice test.',
                  primaryColor: primaryBlue,
                ),

                const SizedBox(height: 15),

                ContentIdeaCard(
                  title: 'High Save Potential',
                  badgeText: 'Content Opportunity',
                  emoji: '💡',
                  description:
                      'Top 3 affordable eats content gets more saves. Try budget-friendly list.',
                  primaryColor: primaryBlue,
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // NAVBAR
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

// ===============================
// CONTENT IDEA CARD
// ===============================
class ContentIdeaCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final String emoji;
  final String description;
  final Color primaryColor;

  const ContentIdeaCard({
    super.key,
    required this.title,
    required this.badgeText,
    required this.emoji,
    required this.description,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Text(emoji),
              const SizedBox(width: 4),
              Text(
                badgeText,
                style: TextStyle(color: primaryColor.withOpacity(0.8)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: primaryColor.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 12),

          // 🔥 BUTTON GENERATE SCRIPT
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScriptResultPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA6B7FF).withOpacity(0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Generate Script',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
