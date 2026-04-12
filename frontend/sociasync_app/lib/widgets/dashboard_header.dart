import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    this.primaryColor = const Color(0xFF1D5093),
    this.onNotificationTap,
    this.unreadCount,
  });

  final String userName;
  final Color primaryColor;
  final VoidCallback? onNotificationTap;
  final int? unreadCount;

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
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed:
                  onNotificationTap ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
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
            if ((unreadCount ?? 0) > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    (unreadCount ?? 0) > 99 ? '99+' : '${unreadCount ?? 0}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
