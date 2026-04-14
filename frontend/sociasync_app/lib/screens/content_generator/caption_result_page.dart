import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociasync_app/screens/content_generator/saved_content_page.dart';
import 'package:sociasync_app/services/content_generator_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class CaptionResultPage extends StatefulWidget {
  const CaptionResultPage({
    super.key,
    required this.requestData,
    required this.selectedIdea,
    required this.scriptData,
    required this.initialCaption,
    required this.initialHashtags,
  });

  final Map<String, String> requestData;
  final Map<String, dynamic> selectedIdea;
  final Map<String, dynamic> scriptData;
  final String initialCaption;
  final List<String> initialHashtags;

  @override
  State<CaptionResultPage> createState() => _CaptionResultPageState();
}

class _CaptionResultPageState extends State<CaptionResultPage> {
  static const primaryColor = Color(0xFF1D5093);
  static const cardBgColor = Color(0xFFE8EFFF);

  late String caption;
  late List<String> hashtags;
  bool _isGeneratingCaption = false;
  bool _isGeneratingHashtags = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    caption = widget.initialCaption;
    hashtags = List<String>.from(widget.initialHashtags);
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _regenerateCaption() async {
    if (_isGeneratingCaption) return;
    setState(() => _isGeneratingCaption = true);

    try {
      final result = await ContentGeneratorService.generateCaption(
        platform: widget.requestData['platform'] ?? 'TikTok',
        tone: widget.requestData['tone'] ?? 'Friendly',
      );

      if (!mounted) return;
      setState(() => caption = result);
    } on ContentGeneratorServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isGeneratingCaption = false);
      }
    }
  }

  Future<void> _regenerateHashtags() async {
    if (_isGeneratingHashtags) return;
    setState(() => _isGeneratingHashtags = true);

    try {
      final result = await ContentGeneratorService.generateHashtags(
        platform: widget.requestData['platform'] ?? 'TikTok',
        topic: widget.requestData['topic'] ?? '',
        tone: widget.requestData['tone'] ?? 'Friendly',
      );

      if (!mounted) return;
      setState(() => hashtags = result);
    } on ContentGeneratorServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isGeneratingHashtags = false);
      }
    }
  }

  Future<void> _saveContent() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      await ContentGeneratorService.saveContent(
        topic: widget.requestData['topic'] ?? '',
        platform: widget.requestData['platform'] ?? '',
        idea: widget.selectedIdea,
        script: widget.scriptData,
        caption: caption,
        hashtags: hashtags,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konten berhasil disimpan.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SavedContentPage()),
      );
    } on ContentGeneratorServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
        MaterialPageRoute(builder: (_) => const ChatbotPage()),
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
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: primaryColor,
                                ),
                              ),
                              const Text(
                                'Caption & Hashtag',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildResultCard(
                            title: '✍️ Caption Ideas',
                            description:
                                'Compelling captions drive higher engagement. Use urgency or curiosity.',
                            content: caption,
                            buttonLabel: _isGeneratingCaption
                                ? 'Generating...'
                                : 'Generate Other Captions',
                            onCopy: () =>
                                _copyToClipboard(caption, 'Caption copied!'),
                            onRefresh: _isGeneratingCaption
                                ? null
                                : _regenerateCaption,
                          ),
                          const SizedBox(height: 40),
                          _buildResultCard(
                            title: '# Smart Hashtag Mix',
                            description:
                                'Using a mix of broad + niche hashtags can increase reach.',
                            content: 'Recommended set:\n${hashtags.join("\n")}',
                            buttonLabel: _isGeneratingHashtags
                                ? 'Generating...'
                                : 'Generate Other Hashtags',
                            onCopy: () => _copyToClipboard(
                              hashtags.join(' '),
                              'Hashtags copied!',
                            ),
                            onRefresh: _isGeneratingHashtags
                                ? null
                                : _regenerateHashtags,
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveContent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  _isSaving ? 'Saving...' : 'SAVE CONTENT',
                                  style: const TextStyle(
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
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: -1,
          backgroundColor: primaryColor,
          onTap: _onNavbarTap,
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
    required VoidCallback? onRefresh,
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
