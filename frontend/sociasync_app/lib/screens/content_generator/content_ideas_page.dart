import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/content_generator/script_result_page.dart';
import 'package:sociasync_app/services/content_generator_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class ContentIdeasPage extends StatefulWidget {
  const ContentIdeasPage({
    super.key,
    required this.requestData,
    required this.ideas,
  });

  final Map<String, String> requestData;
  final List<Map<String, dynamic>> ideas;

  @override
  State<ContentIdeasPage> createState() => _ContentIdeasPageState();
}

class _ContentIdeasPageState extends State<ContentIdeasPage> {
  final int _currentIndex = -1;
  final Color primaryBlue = const Color(0xFF1D5093);
  int? _loadingIndex;

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
        MaterialPageRoute(builder: (_) => const ChatbotPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  Future<void> _generateScriptForIdea(
    Map<String, dynamic> idea,
    int index,
  ) async {
    if (_loadingIndex != null) return;

    final title = (idea['title'] ?? '').toString().trim();
    final description = (idea['description'] ?? '').toString().trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data ide belum lengkap.')));
      return;
    }

    setState(() => _loadingIndex = index);
    try {
      final script = await ContentGeneratorService.generateScript(
        title: title,
        description: description,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScriptResultPage(
            requestData: widget.requestData,
            selectedIdea: {
              'title': title,
              'description': description,
              'type': (idea['type'] ?? '').toString(),
            },
            scriptData: {
              'hook': (script['hook'] ?? '').toString(),
              'body': (script['body'] ?? '').toString(),
              'cta': (script['cta'] ?? '').toString(),
            },
          ),
        ),
      );
    } on ContentGeneratorServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _loadingIndex = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(userName: 'Rina', primaryColor: primaryBlue),
                  const SizedBox(height: 20),
                  const Text(
                    'Content Generator',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.requestData['platform']} • ${widget.requestData['topic']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A6E93),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Content Ideas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D5093),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (widget.ideas.isEmpty)
                    const Text(
                      'Belum ada ide yang bisa ditampilkan.',
                      style: TextStyle(color: Color(0xFF4D5E7C)),
                    )
                  else
                    ...widget.ideas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final idea = entry.value;
                      final type = (idea['type'] ?? 'Content Opportunity')
                          .toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ContentIdeaCard(
                          title: (idea['title'] ?? 'Untitled Idea').toString(),
                          badgeText: type,
                          emoji: type.toLowerCase().contains('comment')
                              ? '🔥'
                              : '💡',
                          description: (idea['description'] ?? '-').toString(),
                          primaryColor: primaryBlue,
                          loading: _loadingIndex == index,
                          onGenerateScript: () =>
                              _generateScriptForIdea(idea, index),
                        ),
                      );
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: _currentIndex,
          backgroundColor: primaryBlue,
          onTap: _onNavbarTap,
        ),
      ),
    );
  }
}

class ContentIdeaCard extends StatelessWidget {
  const ContentIdeaCard({
    super.key,
    required this.title,
    required this.badgeText,
    required this.emoji,
    required this.description,
    required this.primaryColor,
    required this.onGenerateScript,
    this.loading = false,
  });

  final String title;
  final String badgeText;
  final String emoji;
  final String description;
  final Color primaryColor;
  final VoidCallback onGenerateScript;
  final bool loading;

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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
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
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton(
              onPressed: loading ? null : onGenerateScript,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA6B7FF).withOpacity(0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                loading ? 'Generating...' : 'Generate Script',
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
