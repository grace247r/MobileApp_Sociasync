import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociasync_app/screens/content_generator/caption_result_page.dart';
import 'package:sociasync_app/services/content_generator_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class ScriptResultPage extends StatefulWidget {
  const ScriptResultPage({
    super.key,
    required this.requestData,
    required this.selectedIdea,
    required this.scriptData,
  });

  final Map<String, String> requestData;
  final Map<String, dynamic> selectedIdea;
  final Map<String, dynamic> scriptData;

  @override
  State<ScriptResultPage> createState() => _ScriptResultPageState();
}

class _ScriptResultPageState extends State<ScriptResultPage> {
  static const Color primaryColor = Color(0xFF1A237E);

  late Map<String, dynamic> _script;
  bool _isRegenerating = false;
  bool _isGeneratingCaption = false;

  @override
  void initState() {
    super.initState();
    _script = Map<String, dynamic>.from(widget.scriptData);
  }

  String get _hook => (_script['hook'] ?? '').toString();
  String get _body => (_script['body'] ?? '').toString();
  String get _cta => (_script['cta'] ?? '').toString();

  void copyFullScript(BuildContext context) {
    final fullScript = [
      _hook,
      _body,
      _cta,
    ].where((v) => v.isNotEmpty).join('\n\n');
    Clipboard.setData(ClipboardData(text: fullScript));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Full script copied!')));
  }

  void copySingle(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied!')));
  }

  Future<void> _generateNewScript() async {
    if (_isRegenerating) return;

    setState(() => _isRegenerating = true);
    try {
      final script = await ContentGeneratorService.generateScript(
        title: (widget.selectedIdea['title'] ?? '').toString(),
        description: (widget.selectedIdea['description'] ?? '').toString(),
        previousHook: _hook,
        previousBody: _body,
        previousCta: _cta,
      );

      if (!mounted) return;
      setState(() {
        _script = {
          'hook': (script['hook'] ?? '').toString(),
          'body': (script['body'] ?? '').toString(),
          'cta': (script['cta'] ?? '').toString(),
        };
      });
    } on ContentGeneratorServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }

  Future<void> _goToCaptionPage() async {
    if (_isGeneratingCaption) return;

    setState(() => _isGeneratingCaption = true);
    try {
      final caption = await ContentGeneratorService.generateCaption(
        platform: widget.requestData['platform'] ?? 'TikTok',
        tone: widget.requestData['tone'] ?? 'Friendly',
      );
      final hashtags = await ContentGeneratorService.generateHashtags(
        platform: widget.requestData['platform'] ?? 'TikTok',
        topic: widget.requestData['topic'] ?? '',
        tone: widget.requestData['tone'] ?? 'Friendly',
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CaptionResultPage(
            requestData: widget.requestData,
            selectedIdea: widget.selectedIdea,
            scriptData: _script,
            initialCaption: caption,
            initialHashtags: hashtags,
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
        setState(() => _isGeneratingCaption = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios, size: 20),
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Video Content Script',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (widget.selectedIdea['title'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildScriptTimelineItem(
                        primaryColor,
                        time: '00:00 - 00:03',
                        label: 'HOOK',
                        script: _hook,
                        onCopy: () => copySingle(_hook),
                      ),
                      _buildScriptTimelineItem(
                        primaryColor,
                        time: '00:03 - 00:08',
                        label: 'BODY',
                        script: _body,
                        onCopy: () => copySingle(_body),
                      ),
                      _buildScriptTimelineItem(
                        primaryColor,
                        time: '00:08 - 00:12',
                        label: 'CTA',
                        script: _cta,
                        onCopy: () => copySingle(_cta),
                      ),
                      const SizedBox(height: 24),
                      _buildPrimaryButton(
                        label: 'Copy Full Script',
                        icon: Icons.copy_all_rounded,
                        color: primaryColor,
                        isPrimary: true,
                        onPressed: () => copyFullScript(context),
                      ),
                      const SizedBox(height: 12),
                      _buildPrimaryButton(
                        label: _isRegenerating
                            ? 'Generating...'
                            : 'Generate Other Script',
                        icon: Icons.refresh_rounded,
                        color: primaryColor,
                        isPrimary: false,
                        onPressed: _isRegenerating ? null : _generateNewScript,
                      ),
                      const SizedBox(height: 12),
                      _buildPrimaryButton(
                        label: _isGeneratingCaption
                            ? 'Generating...'
                            : 'Generate Caption + Hashtag',
                        icon: Icons.auto_awesome,
                        color: primaryColor,
                        isPrimary: false,
                        onPressed: _isGeneratingCaption
                            ? null
                            : _goToCaptionPage,
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
    );
  }

  Widget _buildScriptTimelineItem(
    Color color, {
    required String time,
    required String label,
    required String script,
    required VoidCallback onCopy,
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
                      GestureDetector(
                        onTap: onCopy,
                        child: const Icon(
                          Icons.copy_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 25),
                  Text(
                    script.isEmpty ? '-' : script,
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

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isPrimary,
    required VoidCallback? onPressed,
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
