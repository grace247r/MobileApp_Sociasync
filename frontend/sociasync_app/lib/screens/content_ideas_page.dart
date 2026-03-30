import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/screens/dashboard_page.dart';
import 'package:sociasync_app/screens/notification_page.dart';
import 'package:sociasync_app/screens/loadinggeneratorpage.dart';

class ContentIdeasPage extends StatefulWidget {
  const ContentIdeasPage({super.key});

  @override
  State<ContentIdeasPage> createState() => _ContentIdeasPageState();
}

class _ContentIdeasPageState extends State<ContentIdeasPage> {
  int _currentIndex = 2;

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
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
      return;
    }

    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Halaman profil belum tersedia')),
      );
    }
  }

  final Color primaryBlue = const Color(0xFF1D5093);

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
                // Header Section
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

                // Daftar Ide Konten menggunakan widget kartu kamu
                ContentIdeaCard(
                  title: 'Street Food Hook',
                  badgeText: 'Content Opportunity',
                  emoji: '💡',
                  description:
                      'Street food videos under 45 seconds are generating higher watch time this week. Try a quick "first bite reaction" with price overlay.',
                  primaryColor: primaryBlue,
                ),
                const SizedBox(height: 15),

                ContentIdeaCard(
                  title: 'Engagement Booster',
                  badgeText: 'Comment Driver',
                  emoji: '🔥',
                  description:
                      'Spicy level challenge content is driving more comments in your niche. Create a "Level 1-5 spice test" and ask followers to rate it.',
                  primaryColor: primaryBlue,
                ),
                const SizedBox(height: 15),

                ContentIdeaCard(
                  title: 'High Save Potential',
                  badgeText: 'Content Opportunity',
                  emoji: '💡',
                  description:
                      'Carousel posts featuring "Top 3 Affordable Eats" are getting more saves. Consider posting a budget-friendly food list in your area.',
                  primaryColor: primaryBlue,
                ),
                const SizedBox(height: 30),

                // --- SECTION CAPTION IDEAS ---
                const Text(
                  'Caption Ideas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D5093),
                  ),
                ),
                const SizedBox(height: 15),

                GeneratorCard(
                  title: '📝 High-Engagement Format',
                  description:
                      'Captions that ask a question at the end are driving more comments. Add a simple CTA to encourage interaction.',
                  previewText:
                      'Preview :\n“Would you try this for only 20K? 👀”',
                  buttonText: 'Generate Other Caption',
                  onPressed: () {},
                ),
                const SizedBox(height: 15),

                GeneratorCard(
                  title: '✍️ Caption Idea Ready',
                  description:
                      'Short storytelling captions are increasing engagement this week. Try a casual tone with a strong hook in the first sentence.',
                  previewText:
                      'Preview:\n“Didn’t expect this small stall to taste THIS good...”',
                  buttonText: 'Generate Other Caption',
                  onPressed: () {},
                ),
                const SizedBox(height: 30),

                // --- SECTION HASHTAG IDEAS ---
                const Text(
                  'Hashtag Ideas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D5093),
                  ),
                ),
                const SizedBox(height: 15),

                GeneratorCard(
                  title: '# Smart Hashtag Mix',
                  description:
                      'Using a mix of broad + niche hashtags can increase reach.',
                  previewText:
                      'Recommended set for your next post:\n#streetfood #kulinerjakarta #foodreview #jajanmurah #foodvlogger',
                  buttonText: 'Generate Other Hashtags',
                  onPressed: () {},
                ),
                const SizedBox(height: 40),

                // --- FINAL GENERATE BUTTON ---
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // PINDAH KE SCREEN LOADING TERPISAH
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoadingGeneratorPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D5093), // primaryBlue
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'GENERATE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Jarak untuk Navbar
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
}

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
      margin: const EdgeInsets.only(bottom: 15),
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
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: primaryColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    const baseColor = Color(0xFFA6B7FF);
                    if (states.contains(MaterialState.pressed)) {
                      return baseColor.withOpacity(0.76);
                    }
                    return baseColor.withOpacity(0.41);
                  }),
                  elevation: const MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
          ),
        ],
      ),
    );
  }
}

class GeneratorCard extends StatelessWidget {
  final String title;
  final String description;
  final String previewText;
  final String buttonText;
  final VoidCallback onPressed;

  const GeneratorCard({
    super.key,
    required this.title,
    required this.description,
    required this.previewText,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1D5093);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: primaryColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              previewText,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: primaryColor.withOpacity(0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    const baseColor = Color(0xFFA6B7FF);
                    if (states.contains(MaterialState.pressed)) {
                      return baseColor.withOpacity(0.76);
                    }
                    return baseColor.withOpacity(0.41);
                  }),
                  elevation: const MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
