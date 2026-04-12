import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/services/auth_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  bool _isLoading = true;
  bool _isSaving = false;

  // Toggle states
  bool likesEnabled = false;
  bool commentsEnabled = false;
  bool newFollowersEnabled = false;
  bool profileViewsEnabled = false;
  bool postInteractedEnabled = true;

  bool inAppAllEnabled = true;
  bool inAppSoundEnabled = true;
  bool inAppVibrationEnabled = false;
  bool inAppBannerEnabled = true;

  String pushSchedule = 'Always';

  bool emailNewsletterEnabled = true;
  bool emailActivitySummaryEnabled = false;
  bool emailSecurityAlertsEnabled = true;
  bool emailPromotionsEnabled = false;

  bool smsEnabled = false;
  String smsFrequency = 'Instantly';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final data = await AuthService.getNotificationSettings();
      if (!mounted) return;
      setState(() {
        likesEnabled = data['likes_enabled'] ?? likesEnabled;
        commentsEnabled = data['comments_enabled'] ?? commentsEnabled;
        newFollowersEnabled =
            data['new_followers_enabled'] ?? newFollowersEnabled;
        profileViewsEnabled =
            data['profile_views_enabled'] ?? profileViewsEnabled;
        postInteractedEnabled =
            data['post_interacted_enabled'] ?? postInteractedEnabled;

        inAppAllEnabled = data['in_app_all_enabled'] ?? inAppAllEnabled;
        inAppSoundEnabled = data['in_app_sound'] ?? inAppSoundEnabled;
        inAppVibrationEnabled =
            data['in_app_vibration'] ?? inAppVibrationEnabled;
        inAppBannerEnabled = data['in_app_banner'] ?? inAppBannerEnabled;

        pushSchedule = _scheduleApiToLabel(
          (data['push_schedule'] ?? '').toString(),
        );

        emailNewsletterEnabled =
            data['email_newsletter'] ?? emailNewsletterEnabled;
        emailActivitySummaryEnabled =
            data['email_activity_summary'] ?? emailActivitySummaryEnabled;
        emailSecurityAlertsEnabled =
            data['email_security_alerts'] ?? emailSecurityAlertsEnabled;
        emailPromotionsEnabled =
            data['email_promotions'] ?? emailPromotionsEnabled;

        smsEnabled = data['sms_enabled'] ?? smsEnabled;
        smsFrequency = _smsApiToLabel((data['sms_frequency'] ?? '').toString());

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings({bool showMessage = false}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await AuthService.updateNotificationSettings({
        'likes_enabled': likesEnabled,
        'comments_enabled': commentsEnabled,
        'new_followers_enabled': newFollowersEnabled,
        'profile_views_enabled': profileViewsEnabled,
        'post_interacted_enabled': postInteractedEnabled,
        'in_app_all_enabled': inAppAllEnabled,
        'in_app_sound': inAppSoundEnabled,
        'in_app_vibration': inAppVibrationEnabled,
        'in_app_banner': inAppBannerEnabled,
        'push_schedule': _scheduleLabelToApi(pushSchedule),
        'email_newsletter': emailNewsletterEnabled,
        'email_activity_summary': emailActivitySummaryEnabled,
        'email_security_alerts': emailSecurityAlertsEnabled,
        'email_promotions': emailPromotionsEnabled,
        'sms_enabled': smsEnabled,
        'sms_frequency': _smsLabelToApi(smsFrequency),
      });

      if (!mounted) return;
      if (showMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings saved.')));
      }
    } on AuthException catch (e) {
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

  String _scheduleLabelToApi(String value) {
    switch (value) {
      case 'During work hours (9AM - 6PM)':
        return 'work_hours';
      case 'Custom schedule':
        return 'custom';
      default:
        return 'always';
    }
  }

  String _scheduleApiToLabel(String value) {
    switch (value) {
      case 'work_hours':
        return 'During work hours (9AM - 6PM)';
      case 'custom':
        return 'Custom schedule';
      default:
        return 'Always';
    }
  }

  String _smsLabelToApi(String value) {
    switch (value) {
      case 'Daily digest':
        return 'daily';
      case 'Weekly digest':
        return 'weekly';
      default:
        return 'instantly';
    }
  }

  String _smsApiToLabel(String value) {
    switch (value) {
      case 'daily':
        return 'Daily digest';
      case 'weekly':
        return 'Weekly digest';
      default:
        return 'Instantly';
    }
  }

  // ── In-app notifications popup ──
  void _showInAppDialog() {
    bool allInApp = inAppAllEnabled;
    bool sound = inAppSoundEnabled;
    bool vibration = inAppVibrationEnabled;
    bool banner = inAppBannerEnabled;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'In-App Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogSwitchTile(
                label: 'Enable all in-app notifications',
                value: allInApp,
                onChanged: (v) => setDialogState(() => allInApp = v),
                setDialogState: setDialogState,
              ),
              const Divider(height: 20),
              _dialogSwitchTile(
                label: 'Sound',
                value: sound,
                onChanged: (v) => setDialogState(() => sound = v),
                setDialogState: setDialogState,
              ),
              _dialogSwitchTile(
                label: 'Vibration',
                value: vibration,
                onChanged: (v) => setDialogState(() => vibration = v),
                setDialogState: setDialogState,
              ),
              _dialogSwitchTile(
                label: 'Banner',
                value: banner,
                onChanged: (v) => setDialogState(() => banner = v),
                setDialogState: setDialogState,
              ),
            ],
          ),
          actions: _dialogActions(context, () async {
            setState(() {
              inAppAllEnabled = allInApp;
              inAppSoundEnabled = sound;
              inAppVibrationEnabled = vibration;
              inAppBannerEnabled = banner;
            });
            await _saveSettings(showMessage: true);
          }),
        ),
      ),
    );
  }

  // ── Push notification schedule popup ──
  void _showPushScheduleDialog() {
    String selected = pushSchedule;
    const options = [
      'Always',
      'During work hours (9AM - 6PM)',
      'Custom schedule',
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Push Notification Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose when you want to receive push notifications:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              ...options.map(
                (option) => RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(option, style: const TextStyle(fontSize: 14)),
                  value: option,
                  groupValue: selected,
                  activeColor: primaryBlue,
                  onChanged: (v) => setDialogState(() => selected = v!),
                ),
              ),
            ],
          ),
          actions: _dialogActions(context, () async {
            setState(() => pushSchedule = selected);
            await _saveSettings(showMessage: true);
          }),
        ),
      ),
    );
  }

  // ── Email notifications popup ──
  void _showEmailDialog() {
    bool newsletter = emailNewsletterEnabled;
    bool activitySummary = emailActivitySummaryEnabled;
    bool securityAlerts = emailSecurityAlertsEnabled;
    bool promotions = emailPromotionsEnabled;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Email Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogSwitchTile(
                label: 'Newsletter',
                value: newsletter,
                onChanged: (v) => setDialogState(() => newsletter = v),
                setDialogState: setDialogState,
              ),
              _dialogSwitchTile(
                label: 'Activity summary',
                value: activitySummary,
                onChanged: (v) => setDialogState(() => activitySummary = v),
                setDialogState: setDialogState,
              ),
              _dialogSwitchTile(
                label: 'Security alerts',
                value: securityAlerts,
                onChanged: (v) => setDialogState(() => securityAlerts = v),
                setDialogState: setDialogState,
              ),
              _dialogSwitchTile(
                label: 'Promotions & offers',
                value: promotions,
                onChanged: (v) => setDialogState(() => promotions = v),
                setDialogState: setDialogState,
              ),
            ],
          ),
          actions: _dialogActions(context, () async {
            setState(() {
              emailNewsletterEnabled = newsletter;
              emailActivitySummaryEnabled = activitySummary;
              emailSecurityAlertsEnabled = securityAlerts;
              emailPromotionsEnabled = promotions;
            });
            await _saveSettings(showMessage: true);
          }),
        ),
      ),
    );
  }

  // ── SMS notifications popup ──
  void _showSmsDialog() {
    bool localSmsEnabled = smsEnabled;
    String frequency = smsFrequency;
    const freqOptions = ['Instantly', 'Daily digest', 'Weekly digest'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'SMS Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogSwitchTile(
                label: 'Enable SMS notifications',
                value: localSmsEnabled,
                onChanged: (v) => setDialogState(() => localSmsEnabled = v),
                setDialogState: setDialogState,
              ),
              const Divider(height: 20),
              const Text(
                'Frequency',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              ...freqOptions.map(
                (option) => RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(option, style: const TextStyle(fontSize: 14)),
                  value: option,
                  groupValue: frequency,
                  activeColor: primaryBlue,
                  onChanged: (v) => setDialogState(() => frequency = v!),
                ),
              ),
            ],
          ),
          actions: _dialogActions(context, () async {
            setState(() {
              smsEnabled = localSmsEnabled;
              smsFrequency = frequency;
            });
            await _saveSettings(showMessage: true);
          }),
        ),
      ),
    );
  }

  List<Widget> _dialogActions(
    BuildContext ctx,
    Future<void> Function() onSave,
  ) => [
    TextButton(
      onPressed: () => Navigator.pop(ctx),
      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
    ),
    ElevatedButton(
      onPressed: () async {
        Navigator.pop(ctx);
        await onSave();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Save', style: TextStyle(color: Colors.white)),
    ),
  ];

  Widget _dialogSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required StateSetter setDialogState,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF1D5093),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // "Notification" label
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8, left: 2),
                            child: Text(
                              'Notification',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Group 1: In-app + Push schedule
                          _buildGroup([
                            _buildArrowTile(
                              'In-app notifications',
                              onTap: _showInAppDialog,
                            ),
                            _buildDivider(),
                            _buildArrowTile(
                              'Push notification schedule',
                              onTap: _showPushScheduleDialog,
                            ),
                          ]),

                          const SizedBox(height: 16),

                          // Group 2: Toggles
                          _buildGroup([
                            _buildToggleTile('Likes', likesEnabled, (v) {
                              setState(() => likesEnabled = v);
                              _saveSettings();
                            }),
                            _buildDivider(),
                            _buildToggleTile('Comments', commentsEnabled, (v) {
                              setState(() => commentsEnabled = v);
                              _saveSettings();
                            }),
                            _buildDivider(),
                            _buildToggleTile(
                              'New followers',
                              newFollowersEnabled,
                              (v) {
                                setState(() => newFollowersEnabled = v);
                                _saveSettings();
                              },
                            ),
                            _buildDivider(),
                            _buildToggleTile(
                              'Profile views',
                              profileViewsEnabled,
                              (v) {
                                setState(() => profileViewsEnabled = v);
                                _saveSettings();
                              },
                            ),
                            _buildDivider(),
                            _buildToggleTile(
                              'Post you interacted with',
                              postInteractedEnabled,
                              (v) {
                                setState(() => postInteractedEnabled = v);
                                _saveSettings();
                              },
                            ),
                          ]),

                          const SizedBox(height: 16),

                          // Group 3: Email + SMS
                          _buildGroup([
                            _buildArrowTile(
                              'Email notifications',
                              onTap: _showEmailDialog,
                            ),
                            _buildDivider(),
                            _buildArrowTile(
                              'SMS notifications',
                              onTap: _showSmsDialog,
                            ),
                          ]),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: 3,
          backgroundColor: primaryBlue,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              return;
            }

            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
              );
              return;
            }

            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotPage()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D5093), Color(0xFF2A6EC5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 8,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Notification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildArrowTile(String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: primaryBlue,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
