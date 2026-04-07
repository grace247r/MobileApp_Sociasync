import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociasync_app/screens/content_generator/caption_result_page.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/inbox/inbox_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class ScriptResultPage extends StatefulWidget {
  const ScriptResultPage({super.key});

  @override
  State<ScriptResultPage> createState() => _ScriptResultPageState();
}

class _ScriptResultPageState extends State<ScriptResultPage> {
  static const Color primaryColor = Color(0xFF1A237E);

  List<Map<String, String>> scripts = [
    {
      "time": "00:00 - 00:03",
      "label": "HOOK",
      "visual": "Close-up makanan digigit (lumer).",
      "script": "Gila sih, teksturnya lumer banget!",
    },
    {
      "time": "00:03 - 00:08",
      "label": "BODY",
      "visual": "Shoot suasana kedai yang ramai/antre.",
      "script": "Ini bener-bener hidden gem yang wajib kalian coba minggu ini.",
    },
    {
      "time": "00:08 - 00:12",
      "label": "CTA",
      "visual": "Tunjukkan lokasi/peta di akhir video.",
      "script": "Jujur, worth it parah! Buruan ke sini sebelum makin rame.",
    },
  ];

  // 🔁 Generate Script Baru
  void generateNewScript() {
    setState(() {
      scripts = [
        {
          "time": "00:00 - 00:03",
          "label": "HOOK",
          "visual": "Minuman dituang slow motion.",
          "script": "Demi apa ini seger banget!",
        },
        {
          "time": "00:03 - 00:08",
          "label": "BODY",
          "visual": "Ambience cafe aesthetic.",
          "script": "Tempatnya cozy banget buat nongkrong santai.",
        },
        {
          "time": "00:08 - 00:12",
          "label": "CTA",
          "visual": "Shot depan cafe + signage.",
          "script": "Save dulu, terus langsung cobain ya!",
        },
      ];
    });
  }

  // 📋 Copy full script
  void copyFullScript(BuildContext context) {
    final fullScript = scripts.map((e) => e["script"]).join("\n\n");

    Clipboard.setData(ClipboardData(text: fullScript));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Full script copied!")));
  }

  // 📋 Copy per item
  void copySingle(String text) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied!")));
  }

  // 👉 Navigate ke caption page
  void goToCaptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaptionResultPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // HEADER
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: DashboardHeader(userName: 'Rina'),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios, size: 20),
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Video Content Script",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Ready to shoot? Follow the timeline below.",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),

                      const SizedBox(height: 30),

                      // TIMELINE
                      ...scripts.map((item) {
                        return _buildScriptTimelineItem(
                          primaryColor,
                          time: item["time"]!,
                          label: item["label"]!,
                          visual: item["visual"]!,
                          script: item["script"]!,
                        );
                      }),

                      const SizedBox(height: 30),

                      // BUTTONS
                      _buildPrimaryButton(
                        label: "Copy Full Script",
                        icon: Icons.copy_all_rounded,
                        color: primaryColor,
                        isPrimary: true,
                        onPressed: () => copyFullScript(context),
                      ),

                      const SizedBox(height: 12),

                      _buildPrimaryButton(
                        label: "Generate Other Script",
                        icon: Icons.refresh_rounded,
                        color: primaryColor,
                        isPrimary: false,
                        onPressed: generateNewScript,
                      ),

                      const SizedBox(height: 12),

                      // 🔥 NEW BUTTON
                      _buildPrimaryButton(
                        label: "Generate Caption + Hashtag",
                        icon: Icons.auto_awesome,
                        color: primaryColor,
                        isPrimary: false,
                        onPressed: goToCaptionPage,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: 0,
          onTap: (index) {
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
          },
        ),
      ),
    );
  }

  // ===============================
  // TIMELINE ITEM
  // ===============================
  Widget _buildScriptTimelineItem(
    Color color, {
    required String time,
    required String label,
    required String visual,
    required String script,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(width: 2, color: color.withOpacity(0.2)),
              ),
            ],
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // 👉 COPY PER ITEM
                      GestureDetector(
                        onTap: () => copySingle(script),
                        child: const Icon(
                          Icons.copy_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Visual: $visual",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const Divider(height: 25),

                  Text(
                    script,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // BUTTON
  // ===============================
  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isPrimary ? Colors.white : color),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.white,
          elevation: 0,
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
