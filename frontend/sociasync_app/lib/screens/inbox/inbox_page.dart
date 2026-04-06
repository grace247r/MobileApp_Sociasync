import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'chat_detail_page.dart';

enum InboxFilter { all, unread, priority, group }

class _InboxChatItemData {
  final String name;
  final String message;
  final String time;
  final bool isUnread;
  final bool isPriority;
  final bool isGroup;

  _InboxChatItemData({
    required this.name,
    required this.message,
    required this.time,
    this.isUnread = false,
    this.isPriority = false,
    this.isGroup = false,
  });
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 2;
  InboxFilter _activeFilter = InboxFilter.all;

  final List<_InboxChatItemData> _chatItems = [
    _InboxChatItemData(
      name: 'Lili',
      message: 'Halo, apa kabar?',
      time: '10:30',
      isUnread: true,
      isPriority: true,
    ),
    _InboxChatItemData(
      name: 'Kevin',
      message: 'Kapan kita janjian?',
      time: '09:15',
      isUnread: false,
      isPriority: true,
    ),
    _InboxChatItemData(
      name: 'Mutiara',
      message: 'Terima kasih atas bantuannya',
      time: '08:45',
      isUnread: true,
      isPriority: false,
    ),
    _InboxChatItemData(
      name: 'Roni',
      message: 'Nanti jam berapa?',
      time: 'Kemarin',
      isUnread: false,
      isPriority: false,
    ),
    _InboxChatItemData(
      name: 'Tasya',
      message: 'Ada update terbaru',
      time: 'Kemarin',
      isUnread: true,
      isGroup: true,
    ),
    _InboxChatItemData(
      name: 'Teddy',
      message: 'Sudah lihat file yang saya kirim?',
      time: 'Senin',
      isUnread: false,
      isPriority: true,
    ),
    _InboxChatItemData(
      name: 'Bahlil',
      message: 'Mari kita diskusikan project ini',
      time: 'Senin',
      isUnread: true,
      isGroup: true,
    ),
    _InboxChatItemData(
      name: 'Faradhila',
      message: 'Sip, sudah dikerjakan',
      time: 'Minggu',
      isUnread: false,
      isPriority: false,
    ),
    _InboxChatItemData(
      name: 'Firman',
      message: 'Jangan lupa meeting jam 3',
      time: 'Minggu',
      isUnread: true,
      isPriority: true,
    ),
  ];

  List<_InboxChatItemData> get _filteredChats {
    switch (_activeFilter) {
      case InboxFilter.unread:
        return _chatItems.where((item) => item.isUnread).toList();
      case InboxFilter.priority:
        return _chatItems.where((item) => item.isPriority).toList();
      case InboxFilter.group:
        return _chatItems.where((item) => item.isGroup).toList();
      case InboxFilter.all:
        return _chatItems;
    }
  }

  int get _unreadCount => _chatItems.where((item) => item.isUnread).length;
  int get _priorityCount => _chatItems.where((item) => item.isPriority).length;
  int get _groupCount => _chatItems.where((item) => item.isGroup).length;

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

    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  Widget _buildFilterChip(InboxFilter filter, String label, int count) {
    final isActive = _activeFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryBlue : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.3)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF666666),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(_InboxChatItemData chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(userName: chat.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  chat.name[0].toUpperCase(),
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF999999),
                      fontWeight: chat.isUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time & unread indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 4),
                if (chat.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Column(
        children: [
          // Content Area (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  DashboardHeader(
                    userName: 'Rina',
                    primaryColor: primaryBlue,
                    onNotificationTap: () {},
                  ),
                  const SizedBox(height: 25),

                  // Title
                  const Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          InboxFilter.all,
                          'Semua',
                          _chatItems.length,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          InboxFilter.unread,
                          'Belum dibaca',
                          _unreadCount,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          InboxFilter.priority,
                          'Prioritas',
                          _priorityCount,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          InboxFilter.group,
                          'Grup',
                          _groupCount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chat list
                  ..._filteredChats.map((chat) => _buildChatItem(chat)),
                ],
              ),
            ),
          ),
          // Navbar - Fixed at bottom
          AppNavbar(
            selectedIndex: _currentIndex,
            onTap: _onNavbarTap,
            backgroundColor: primaryBlue,
          ),
        ],
      ),
    );
  }
}
