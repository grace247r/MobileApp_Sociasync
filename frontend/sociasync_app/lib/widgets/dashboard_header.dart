import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    this.primaryColor = const Color(0xFF1D5093),
    this.onNotificationTap,
  });

  final String userName;
  final Color primaryColor;
  final VoidCallback? onNotificationTap;

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
                text: userName,
                style: TextStyle(color: primaryColor),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // LOGIKA: Berpindah ke halaman NotificationPage saat diklik
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
          icon: Image.asset(
            'assets/alarm.png',
            width: 24,
            height: 24,
            color: primaryColor,
            colorBlendMode: BlendMode.srcIn,
          ),
          splashRadius: 22,
          tooltip: 'Notifications',
        ),
      ],
    );
  }
}
