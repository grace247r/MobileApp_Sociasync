import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/screens/content_generator/saved_content_page.dart';

class GenerationResultPage extends StatefulWidget {
  const GenerationResultPage({super.key});

  @override
  State<GenerationResultPage> createState() => _GenerationResultPageState();
}

class _GenerationResultPageState extends State<GenerationResultPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  final String generatedTitle = "Hidden Gem Street Food Review";
  final String generatedCaption =
      "Didn't expect this small stall to taste THIS good... 🍔🍕🌮\n\n#fyp #foodreview #kulinerjakarta #viral #trending";

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    DashboardHeader(
                      userName: 'Rina',
                      primaryColor: primaryBlue,
                      onNotificationTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      'Content Strategy Result',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D5093),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Visual Storyboard Guide
                    _buildSectionCard(
                      title: "🎬 Visual Storyboard Guide",
                      color: primaryBlue.withOpacity(0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepGuide(
                            "1",
                            "Opening: Hook visual stall makanan yang ramai.",
                          ),
                          _buildStepGuide(
                            "2",
                            "Reaction: Ekspresi gigitan pertama (Aesthetic).",
                          ),
                          _buildStepGuide(
                            "3",
                            "Closing: Tampilkan lokasi & ajakan follow.",
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Suggested Audio: Upbeat Lo-fi Beats",
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Caption & Hashtag Box
                    _buildSectionCard(
                      title: "✍️ Final Caption & Hashtags",
                      color: Colors.white.withOpacity(0.8),
                      child: Text(
                        generatedCaption,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons (Redo & Save)
                    Row(
                      children: [
                        Expanded(
                          child: _buildBtn(
                            "Redo",
                            Colors.white,
                            primaryBlue,
                            () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBtn(
                            "Save to Gallery",
                            primaryBlue.withOpacity(0.1),
                            primaryBlue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SavedContentPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Tombol Schedule ke Calendar
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CalendarWeekPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Schedule to Calendar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: 0,
                backgroundColor: primaryBlue,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  } else if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarWeekPage(),
                      ),
                    );
                  } else if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatbotPage()),
                    );
                  } else if (index == 3) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildStepGuide(String num, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: primaryBlue,
            child: Text(
              num,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String label, Color bg, Color text, VoidCallback onTap) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          side: BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
