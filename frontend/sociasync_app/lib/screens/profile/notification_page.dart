import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  // Toggle states
  bool likesEnabled = false;
  bool commentsEnabled = false;
  bool newFollowersEnabled = false;
  bool profileViewsEnabled = false;
  bool postInteractedEnabled = true;

  // ── In-app notifications popup ──
  void _showInAppDialog() {
    bool allInApp = true;
    bool sound = true;
    bool vibration = false;
    bool banner = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'In-App Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
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
          actions: _dialogActions(context),
        ),
      ),
    );
  }

  // ── Push notification schedule popup ──
  void _showPushScheduleDialog() {
    String selected = 'Always';
    const options = ['Always', 'During work hours (9AM - 6PM)', 'Custom schedule'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Push Notification Schedule',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose when you want to receive push notifications:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              ...options.map((option) => RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(option, style: const TextStyle(fontSize: 14)),
                value: option,
                groupValue: selected,
                activeColor: primaryBlue,
                onChanged: (v) => setDialogState(() => selected = v!),
              )),
            ],
          ),
          actions: _dialogActions(context),
        ),
      ),
    );
  }

  // ── Email notifications popup ──
  void _showEmailDialog() {
    bool newsletter = true;
    bool activitySummary = false;
    bool securityAlerts = true;
    bool promotions = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Email Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
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
          actions: _dialogActions(context),
        ),
      ),
    );
  }

  // ── SMS notifications popup ──
  void _showSmsDialog() {
    bool smsEnabled = false;
    String frequency = 'Instantly';
    const freqOptions = ['Instantly', 'Daily digest', 'Weekly digest'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'SMS Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogSwitchTile(
                label: 'Enable SMS notifications',
                value: smsEnabled,
                onChanged: (v) => setDialogState(() => smsEnabled = v),
                setDialogState: setDialogState,
              ),
              const Divider(height: 20),
              const Text(
                'Frequency',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              ...freqOptions.map((option) => RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(option, style: const TextStyle(fontSize: 14)),
                value: option,
                groupValue: frequency,
                activeColor: primaryBlue,
                onChanged: (v) => setDialogState(() => frequency = v!),
              )),
            ],
          ),
          actions: _dialogActions(context),
        ),
      ),
    );
  }

  List<Widget> _dialogActions(BuildContext ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
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
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF1D5093),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    _buildArrowTile('In-app notifications', onTap: _showInAppDialog),
                    _buildDivider(),
                    _buildArrowTile('Push notification schedule', onTap: _showPushScheduleDialog),
                  ]),

                  const SizedBox(height: 16),

                  // Group 2: Toggles
                  _buildGroup([
                    _buildToggleTile('Likes', likesEnabled,
                        (v) => setState(() => likesEnabled = v)),
                    _buildDivider(),
                    _buildToggleTile('Comments', commentsEnabled,
                        (v) => setState(() => commentsEnabled = v)),
                    _buildDivider(),
                    _buildToggleTile('New followers', newFollowersEnabled,
                        (v) => setState(() => newFollowersEnabled = v)),
                    _buildDivider(),
                    _buildToggleTile('Profile views', profileViewsEnabled,
                        (v) => setState(() => profileViewsEnabled = v)),
                    _buildDivider(),
                    _buildToggleTile('Post you interacted with', postInteractedEnabled,
                        (v) => setState(() => postInteractedEnabled = v)),
                  ]),

                  const SizedBox(height: 16),

                  // Group 3: Email + SMS
                  _buildGroup([
                    _buildArrowTile('Email notifications', onTap: _showEmailDialog),
                    _buildDivider(),
                    _buildArrowTile('SMS notifications', onTap: _showSmsDialog),
                  ]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
                (route) => false,
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
            const Icon(Icons.history, color: Colors.white, size: 30),
            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
                (route) => false,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ],
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
                'Profile',
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

  Widget _buildToggleTile(String label, bool value, ValueChanged<bool> onChanged) {
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
            activeColor: Colors.white,
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