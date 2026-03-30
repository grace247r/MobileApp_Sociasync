import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';

class ChatDetailPage extends StatefulWidget {
  final String userName;

  const ChatDetailPage({super.key, required this.userName});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Halo! Apa kabar?', 'time': '10:30', 'isMe': false},
    {'text': 'Baik baik saja, kamu?', 'time': '10:31', 'isMe': true},
    {
      'text': 'Alhamdulillah, ada yang ingin aku bicarakan',
      'time': '10:32',
      'isMe': false,
    },
    {'text': 'Apa itu? Silakan', 'time': '10:33', 'isMe': true},
  ];

  Widget _buildChatBubble(String message, String time, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? primaryBlue : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF2E2E2E),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF999999),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                _messageController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Color(0xFF2E2E2E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          actions: [],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: _messages
                    .map(
                      (msg) => _buildChatBubble(
                        msg['text'],
                        msg['time'],
                        msg['isMe'],
                      ),
                    )
                    .toList(),
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
