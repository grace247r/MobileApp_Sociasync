import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/content_generator/loadinggeneratorpage.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/inbox/inbox_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class CaptionResultPage extends StatefulWidget {
  const CaptionResultPage({super.key});

  @override
  State<CaptionResultPage> createState() => _CaptionResultPageState();
}

class _CaptionResultPageState extends State<CaptionResultPage> {
  static const primaryColor = Color(0xFF1D5093);
  static const cardBgColor = Color(0xFFE8EFFF);

  String caption = "Didn't expect this small stall to taste THIS good...";
  List<String> hashtags = [
    "#streetfood",
    "#kulinerjakarta",
    "#foodreview",
    "#jajanmurah",
    "#foodvlogger",
  ];

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _onNavbarTap(int index) {
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: DashboardHeader(
                      userName: 'Rina',
                      primaryColor: primaryColor,
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 130),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE + BACK
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                ),
                                color: primaryColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Caption & Hashtags",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // CAPTION SECTION
                          _buildResultCard(
                            title: "✍️ Caption Idea Ready",
                            description:
                                "Short storytelling captions are increasing engagement this week.",
                            content: "Preview:\n\"$caption\"",
                            buttonLabel: "Generate Other Caption",
                            onCopy: () =>
                                _copyToClipboard(caption, "Caption copied!"),
                            onRefresh: () {},
                          ),

                          const SizedBox(height: 25),
                          const Text(
                            "Hashtag Ideas",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // HASHTAG SECTION
                          _buildResultCard(
                            title: "# Smart Hashtag Mix",
                            description:
                                "Using a mix of broad + niche hashtags can increase reach.",
                            content: "Recommended set:\n${hashtags.join("\n")}",
                            buttonLabel: "Generate Other Hashtags",
                            onCopy: () => _copyToClipboard(
                              hashtags.join(" "),
                              "Hashtags copied!",
                            ),
                            onRefresh: () {},
                          ),

                          const SizedBox(height: 40),

                          // TOMBOL MENUJU LOADING -> RESULT
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LoadingGeneratorPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  "GENERATE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NAVBAR POSITIONED (Agar sejajar dengan page lain)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: -1,
                backgroundColor: primaryColor,
                onTap: _onNavbarTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String description,
    required String content,
    required String buttonLabel,
    required VoidCallback onCopy,
    required VoidCallback onRefresh,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Column(
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
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: primaryColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA6B7FF).withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onCopy,
              child: const Icon(
                Icons.copy_rounded,
                size: 20,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
