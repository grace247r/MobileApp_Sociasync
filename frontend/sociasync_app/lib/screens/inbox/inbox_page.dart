import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'chat_detail_page.dart';

enum InboxFilter { all, unread, priority, group }

class _InboxChatItemData {
  const _InboxChatItemData({
    required this.name,
    required this.message,
    required this.time,
    this.isUnread = false,
    this.isPriority = false,
    this.isGroup = false,
  });

  final String name;
  final String message;
  final String time;
  final bool isUnread;
  final bool isPriority;
  final bool isGroup;
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  int _currentIndex = 2; // Index Chat di Navbar
  InboxFilter _activeFilter = InboxFilter.all;

  final List<_InboxChatItemData> _chatItems = const [
    _InboxChatItemData(
      name: 'Lili',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isUnread: true,
      isPriority: true,
    ),
    _InboxChatItemData(
      name: 'Kevin',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isUnread: true,
    ),
    _InboxChatItemData(
      name: 'Mutiara',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isGroup: true,
    ),
    _InboxChatItemData(
      name: 'Roni',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isUnread: true,
      isGroup: true,
    ),
    _InboxChatItemData(
      name: 'Tasya',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isPriority: true,
    ),
    _InboxChatItemData(
      name: 'Teddy',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
    ),
    _InboxChatItemData(
      name: 'Bahlil',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isGroup: true,
    ),
    _InboxChatItemData(
      name: 'Faradhila',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
    ),
    _InboxChatItemData(
      name: 'Firman',
      message: 'Lorem Ipsum dolor si amet',
      time: '12.18 PM',
      isUnread: true,
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

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Hi, Rina)
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {},
                ),
                const SizedBox(height: 25),

                // 2. Judul Inbox
                const Text(
                  'Inbox',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 15),

                // 3. Search Bar / Blue Bar (Sesuai Gambar)
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(height: 15),

                // 4. Filter Chips (All, Unread, Priority, Group)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'All',
                        _activeFilter == InboxFilter.all,
                        () => setState(() => _activeFilter = InboxFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Unread (${_chatItems.where((e) => e.isUnread).length})',
                        _activeFilter == InboxFilter.unread,
                        () =>
                            setState(() => _activeFilter = InboxFilter.unread),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Priority',
                        _activeFilter == InboxFilter.priority,
                        () => setState(
                          () => _activeFilter = InboxFilter.priority,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Group (${_chatItems.where((e) => e.isGroup).length})',
                        _activeFilter == InboxFilter.group,
                        () => setState(() => _activeFilter = InboxFilter.group),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Chat List Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: _filteredChats
                        .map((chat) => _buildChatItem(chat))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // 6. Navbar Melayang
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: _currentIndex,
              backgroundColor: primaryBlue,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Filter Chip
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : primaryBlue.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Baris Chat
  Widget _buildChatItem(_InboxChatItemData chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailPage(userName: chat.name),
            ),
          );
        },
        child: Row(
          children: [
            // Profile Picture sesuai gambar (menggunakan placeholder foto makan)
            const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/150',
              ), // Ganti dengan asset lokal
            ),
            const SizedBox(width: 15),
            // Name & Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.message,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Time
            Text(
              chat.time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
