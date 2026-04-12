import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/services/auth_service.dart';

class DashboardHeader extends StatefulWidget {
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
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  static String? _cachedUserName;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = _normalizeName(widget.userName);
    _tryResolveRealUserName();
  }

  @override
  void didUpdateWidget(covariant DashboardHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName) {
      _displayName = _normalizeName(widget.userName);
      _tryResolveRealUserName();
    }
  }

  String _normalizeName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'User';
    return trimmed;
  }

  bool _isPlaceholderName(String name) {
    final lower = name.toLowerCase();
    return lower == 'rina' || lower == 'user';
  }

  Future<void> _tryResolveRealUserName() async {
    if (!_isPlaceholderName(_displayName)) return;

    if (_cachedUserName != null && _cachedUserName!.trim().isNotEmpty) {
      setState(() => _displayName = _cachedUserName!);
      return;
    }

    try {
      final profile = await AuthService.getMe();
      if (!mounted) return;
      final loadedName = (profile['name'] ?? '').toString().trim();
      if (loadedName.isEmpty) return;
      _cachedUserName = loadedName;
      setState(() => _displayName = loadedName);
    } catch (_) {
      // Keep fallback name when profile cannot be loaded.
    }
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
                text: _displayName,
                style: TextStyle(color: widget.primaryColor),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed:
                  widget.onNotificationTap ??
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
                color: widget.primaryColor,
                colorBlendMode: BlendMode.srcIn,
              ),
              splashRadius: 22,
              tooltip: 'Notifications',
            ),
            if ((widget.unreadCount ?? 0) > 0)
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
                    (widget.unreadCount ?? 0) > 99
                        ? '99+'
                        : '${widget.unreadCount ?? 0}',
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
