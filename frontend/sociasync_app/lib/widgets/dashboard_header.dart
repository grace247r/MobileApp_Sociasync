import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/services/auth_service.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({
    super.key,
    this.primaryColor = const Color(0xFF1D5093),
    this.onNotificationTap,
  });

  final Color primaryColor;
  final VoidCallback? onNotificationTap;

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    AuthService.profileNotifier.addListener(_onProfileChanged);
    _onProfileChanged();
  }

  void _onProfileChanged() {
    final profile = AuthService.currentProfile;
    final nextName = (profile?.name ?? '').trim();
    if (!mounted) return;
    if (_userName == nextName) return;
    setState(() => _userName = nextName.isEmpty ? 'User' : nextName);
  }

  @override
  void dispose() {
    AuthService.profileNotifier.removeListener(_onProfileChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            children: [
              const TextSpan(text: 'Hi, '),
              TextSpan(
                text: _userName,
                style: TextStyle(color: widget.primaryColor),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            if (widget.onNotificationTap != null) {
              widget.onNotificationTap!();
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
          icon: Image.asset(
            'assets/alarm.png',
            width: 24,
            height: 24,
            color: widget.primaryColor,
            colorBlendMode: BlendMode.srcIn,
          ),
          splashRadius: 22,
          tooltip: 'Notifications',
        ),
      ],
    );
  }
}
