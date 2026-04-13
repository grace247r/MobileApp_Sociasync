import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
// Import wrapper background yang kita buat sebelumnya
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/services/auth_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color primaryBlue = Color(0xFF1D5093);
  final int _currentIndex = 0;
  bool _isLoading = true;
  String _userName = 'User';
  List<_NotificationItem> _notifications = const <_NotificationItem>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await AuthService.getMe();
      await AuthService.markAllNotificationsRead();
      final notifications = await AuthService.getNotifications();
      if (!mounted) return;

      final name = (profile['name'] ?? '').toString().trim();
      final mapped = notifications.map(_mapNotification).toList();

      setState(() {
        if (name.isNotEmpty) {
          _userName = name;
        }
        _notifications = mapped
            .map((item) => item.copyWith(isHighlighted: false))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  _NotificationItem _mapNotification(Map<String, dynamic> item) {
    final title = (item['title'] ?? '').toString().trim();
    final message = (item['message'] ?? '').toString().trim();
    final createdAtRaw = (item['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtRaw)?.toLocal();

    final hh = createdAt?.hour.toString().padLeft(2, '0') ?? '--';
    final mm = createdAt?.minute.toString().padLeft(2, '0') ?? '--';
    final isRead = item['is_read'] == true;

    return _NotificationItem(
      title: title.isEmpty ? 'Notification' : title,
      message: message.isEmpty ? '-' : message,
      time: '$hh:$mm',
      isHighlighted: !isRead,
    );
  }

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatbotPage()));
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    userName: _userName,
                    primaryColor: primaryBlue,
                    onNotificationTap: () {},
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Notification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _notifications.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada notifikasi.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _NotificationCard(
                                item: _notifications[index],
                              );
                            },
                          ),
                  ),
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

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // Efek Glassmorphism: Putih transparan dengan sedikit blur dari background
        color: Color.fromRGBO(
          78,
          96,
          189,
          0.10,
        ).withOpacity(0.10), // Opacity harus di rentang 0.0..1.0
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D5093), // Gunakan primaryBlue agar serasi
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.isHighlighted = false,
  });

  final String title;
  final String message;
  final String time;
  final bool isHighlighted;

  _NotificationItem copyWith({
    String? title,
    String? message,
    String? time,
    bool? isHighlighted,
  }) {
    return _NotificationItem(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}
