import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/add_calendar_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/content_generator/saved_content_page.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';

class SavedContentDetailPage extends StatefulWidget {
  const SavedContentDetailPage({super.key, required this.content});

  final SavedStrategy content;

  @override
  State<SavedContentDetailPage> createState() => _SavedContentDetailPageState();
}

class _SavedContentDetailPageState extends State<SavedContentDetailPage> {
  static const primaryBlue = Color(0xFF1D5093);

  String _safeText(String Function() getter) {
    try {
      final value = getter();
      final normalized = value.trim();
      if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
        return '-';
      }
      return normalized;
    } catch (_) {
      return '-';
    }
  }

  String _normalizePlatform(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.contains('tik')) return 'tiktok';
    return 'instagram';
  }

  String _buildNotes() {
    final hashtags = widget.content.hashtags.isEmpty
        ? '-'
        : widget.content.hashtags.join(' ');
    final topic = _safeText(() => widget.content.topic);
    final ideaTitle = _safeText(() => widget.content.ideaTitle);
    final ideaDescription = _safeText(() => widget.content.ideaDescription);
    final scriptHook = _safeText(() => widget.content.scriptHook);
    final scriptBody = _safeText(() => widget.content.scriptBody);
    final scriptCta = _safeText(() => widget.content.scriptCta);
    final caption = _safeText(() => widget.content.caption);

    return [
      'Topic: $topic',
      'Idea: $ideaTitle',
      '',
      'Idea Description:',
      ideaDescription,
      '',
      'Script Hook:',
      scriptHook,
      '',
      'Script Body:',
      scriptBody,
      '',
      'Script CTA:',
      scriptCta,
      '',
      'Caption:',
      caption,
      '',
      'Hashtags:',
      hashtags,
    ].join('\n');
  }

  Future<void> _addToSchedule() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCalendarPage(
          initialData: {
            'title': widget.content.ideaTitle == '-'
                ? widget.content.topic
                : widget.content.ideaTitle,
            'notes': _buildNotes(),
            'platform': _normalizePlatform(widget.content.platform),
            'repeat': 'Never',
            'reminder': '10 mins before',
          },
        ),
      ),
    );

    if (!mounted || created != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Event berhasil ditambahkan ke jadwal.'),
        action: SnackBarAction(
          label: 'Lihat Kalender',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
            );
          },
        ),
      ),
    );
  }

  Widget _section(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryBlue.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final topic = _safeText(() => content.topic);
    final platform = _safeText(() => content.platform);
    final ideaTitle = _safeText(() => content.ideaTitle);
    final ideaDescription = _safeText(() => content.ideaDescription);
    final scriptHook = _safeText(() => content.scriptHook);
    final scriptBody = _safeText(() => content.scriptBody);
    final scriptCta = _safeText(() => content.scriptCta);
    final caption = _safeText(() => content.caption);

    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: primaryBlue,
                            ),
                          ),
                          const Text(
                            'Saved Content Detail',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _section('Topic', topic),
                      _section('Platform', platform),
                      _section('Idea Title', ideaTitle),
                      _section('Idea Description', ideaDescription),
                      _section('Script Hook', scriptHook),
                      _section('Script Body', scriptBody),
                      _section('Script CTA', scriptCta),
                      _section('Caption', caption),
                      _section(
                        'Hashtags',
                        content.hashtags.isEmpty
                            ? '-'
                            : content.hashtags.join(' '),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _addToSchedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Add To Schedule / Reminder',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

