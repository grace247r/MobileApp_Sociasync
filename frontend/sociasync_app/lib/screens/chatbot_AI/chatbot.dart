import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/services/chatbot_service.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'package:sociasync_app/services/reminder_service.dart';

class _ChatMessage {
  const _ChatMessage({required this.role, required this.content});

  final String role;
  final String content;
}

class _ReminderItem {
  const _ReminderItem({
    required this.id,
    required this.to,
    required this.message,
    required this.day,
    required this.time,
  });

  final int id;
  final String to;
  final String message;
  final String day;
  final String time;

  factory _ReminderItem.fromJson(Map<String, dynamic> json) {
    return _ReminderItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      to: (json['to'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
      time: _normalizeTime((json['time'] ?? '').toString()),
    );
  }

  static String _normalizeTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    if (text.length >= 5 && text.contains(':')) {
      return text.substring(0, 5);
    }
    return text;
  }
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 2;

  // 0 = Reminder, 1 = Chatbot AI
  int _activeTab = 0;

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isSendingChat = false;
  bool _isLoadingReminders = false;
  bool _isReminderActionLoading = false;
  List<_ChatMessage> _chatMessages = const <_ChatMessage>[
    _ChatMessage(
      role: 'assistant',
      content:
          'Hi! Aku Sociasync AI. Ceritain goal kontenmu, nanti aku bantu kasih ide dan strategi.',
    ),
  ];

  List<_ReminderItem> _reminders = const <_ReminderItem>[];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
      );
    } else if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatbotPage()));
    } else if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  Future<void> _loadReminders() async {
    if (_isLoadingReminders) return;

    setState(() => _isLoadingReminders = true);
    try {
      final response = await ReminderService.getReminders();
      final reminders = response.map(_ReminderItem.fromJson).toList();
      if (!mounted) return;
      setState(() {
        _reminders = reminders;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isLoadingReminders = false);
      }
    }
  }

  Future<void> _addReminder() async {
    final form = await _showReminderFormDialog();
    if (form == null) return;

    setState(() => _isReminderActionLoading = true);
    try {
      await ReminderService.createReminder(
        to: form['to']!,
        message: form['message']!,
        day: form['day']!,
        time: form['time']!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder berhasil ditambahkan.')),
      );
      await _loadReminders();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isReminderActionLoading = false);
      }
    }
  }

  Future<void> _completeReminder(_ReminderItem item) async {
    if (_isReminderActionLoading) return;

    setState(() => _isReminderActionLoading = true);
    try {
      await ReminderService.completeReminder(reminderId: item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder ditandai selesai.')),
      );
      await _loadReminders();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isReminderActionLoading = false);
      }
    }
  }

  Future<void> _editReminder(_ReminderItem item) async {
    final form = await _showReminderFormDialog(item: item);
    if (form == null) return;

    setState(() => _isReminderActionLoading = true);
    try {
      await ReminderService.updateReminder(
        reminderId: item.id,
        to: form['to']!,
        message: form['message']!,
        day: form['day']!,
        time: form['time']!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder berhasil diubah.')),
      );
      await _loadReminders();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isReminderActionLoading = false);
      }
    }
  }

  Future<Map<String, String>?> _showReminderFormDialog({_ReminderItem? item}) {
    final toController = TextEditingController(text: item?.to ?? '');
    final messageController = TextEditingController(text: item?.message ?? '');
    final dayController = TextEditingController(text: item?.day ?? 'Monday');
    final timeController = TextEditingController(text: item?.time ?? '09:00');

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Tambah Reminder' : 'Edit Reminder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: toController,
                decoration: const InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dayController,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (HH:mm)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final to = toController.text.trim();
              final message = messageController.text.trim();
              final day = dayController.text.trim();
              final time = timeController.text.trim();

              if (to.isEmpty ||
                  message.isEmpty ||
                  day.isEmpty ||
                  time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field wajib diisi.')),
                );
                return;
              }

              Navigator.pop(context, {
                'to': to,
                'message': message,
                'day': day,
                'time': time,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _chatHistoryPayload() {
    return _chatMessages
        .map(
          (item) => <String, String>{
            'role': item.role,
            'content': item.content,
          },
        )
        .toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendChat() async {
    if (_isSendingChat) return;

    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();
    setState(() {
      _chatMessages = [
        ..._chatMessages,
        _ChatMessage(role: 'user', content: text),
      ];
      _isSendingChat = true;
    });
    _scrollToBottom();

    try {
      final reply = await ChatbotService.chat(
        message: text,
        history: _chatHistoryPayload(),
      );

      if (!mounted) return;
      setState(() {
        _chatMessages = [
          ..._chatMessages,
          _ChatMessage(role: 'assistant', content: reply),
        ];
      });
    } on ChatbotServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isSendingChat = false);
        _scrollToBottom();
      }
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
                // 1. WIDGET ATAS: Header yang sudah ada
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {},
                ),
                const SizedBox(height: 15),

                // 2. Title & Back Button (judul diganti jadi 'Chat')
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // 3. MAIN CHAT CONTAINER (Wadah ber-border biru)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryBlue.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        // Blue Header inside Chat Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(19),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/chatbotAI.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Sociasync AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // INNER NAVBAR (Reminder | Chatbot AI)
                        Container(
                          color: Colors.white,
                          child: Row(
                            children: [
                              _buildInnerTab(label: 'Reminders', index: 0),
                              _buildInnerTab(label: 'Chatbot AI', index: 1),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE8E8E8),
                        ),

                        // Konten Tab pakai IndexedStack supaya state tidak reset
                        Expanded(
                          child: IndexedStack(
                            index: _activeTab,
                            children: [
                              // Tab 0: Reminder
                              _buildReminderTab(),
                              // Tab 1: Chatbot AI
                              _buildChatTab(),
                            ],
                          ),
                        ),

                        // Input Area hanya tampil di tab Chatbot AI
                        if (_activeTab == 1) _buildChatInput(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Jarak untuk Navbar
              ],
            ),
          ),

          // 4. WIDGET BAWAH: Navbar Melayang
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: _currentIndex,
              backgroundColor: primaryBlue,
              onTap: _onNavbarTap,
            ),
          ),
        ],
      ),
    );
  }

  // Widget tab button untuk inner navbar
  Widget _buildInnerTab({required String label, required int index}) {
    final bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeTab = index);
          if (index == 0) {
            _loadReminders();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isActive ? primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? primaryBlue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Tab 0: Konten Reminder
  Widget _buildReminderTab() {
    if (_isLoadingReminders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Belum ada reminder.'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isReminderActionLoading ? null : _addReminder,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _reminders.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton.icon(
                  onPressed: _isReminderActionLoading ? null : _addReminder,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            );
          }

          final r = _reminders[i - 1];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To: ${r.to}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.message, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Message: ${r.message}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${r.day} at ${r.time}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isReminderActionLoading
                            ? null
                            : () => _completeReminder(r),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isReminderActionLoading
                            ? null
                            : () => _editReminder(r),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget Bubble Chat Bot
  Widget _buildChatTab() {
    return ListView.builder(
      controller: _chatScrollController,
      padding: const EdgeInsets.all(15),
      itemCount: _chatMessages.length + (_isSendingChat ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isSendingChat && index == _chatMessages.length) {
          return _buildAssistantBubble('Sociasync AI sedang mengetik...');
        }

        final msg = _chatMessages[index];
        if (msg.role == 'user') {
          return _buildUserBubble(msg.content);
        }
        return _buildAssistantBubble(msg.content);
      },
    );
  }

  Widget _buildAssistantBubble(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/chatbotAI.png',
                width: 18,
                height: 18,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryBlue.withOpacity(0.3)),
              ),
              child: Text(content, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Spacer(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Input Chat di bagian bawah container
  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryBlue.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _chatController,
                onSubmitted: (_) => _sendChat(),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan untuk Sociasync AI...',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isSendingChat ? null : _sendChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(
              _isSendingChat ? '...' : 'Kirim',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
