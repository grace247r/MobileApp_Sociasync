import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'chat_detail_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  int _currentIndex = 2; // Index Chat di Navbar

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
                      _buildFilterChip('All', true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unread (15)', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('Priority', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('Group (3)', false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Chat List Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      _buildChatItem(
                        'Lili',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Kevin',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Mutiara',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Roni',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Tasya',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Teddy',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Bahlil',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Faradhila',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                      _buildChatItem(
                        'Firman',
                        'Lorem Ipsum dolor si amet',
                        '12.18 PM',
                      ),
                    ],
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
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
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
    );
  }

  // Widget Helper untuk Baris Chat
  Widget _buildChatItem(String name, String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatDetailPage(userName: name)),
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
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Time
            Text(
              time,
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
