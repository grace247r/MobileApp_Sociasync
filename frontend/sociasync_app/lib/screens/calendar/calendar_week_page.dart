import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_month_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_year_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class CalendarWeekPage extends StatefulWidget {
  const CalendarWeekPage({super.key});

  @override
  State<CalendarWeekPage> createState() => _CalendarWeekPageState();
}

class _CalendarWeekPageState extends State<CalendarWeekPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  DateTime _focusedDate = DateTime(2026, 3, 3);

  final Map<String, List<String>> _events = {
    '2026-03-03': [
      'Deadline Project X',
      'Deadline Project X',
      'Deadline Project X',
      'Deadline Project X',
    ],
    '2026-03-05': ['Team Meeting'],
    '2026-03-07': ['Content Upload', 'Analytics Review'],
  };

  List<DateTime> _getWeekDays(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(9, (i) => monday.add(Duration(days: i)));
  }

  String _eventKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<String> _getEvents(DateTime d) => _events[_eventKey(d)] ?? [];

  String _fullDate(DateTime d) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }

  String _shortDay(DateTime d) {
    const days = ['', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[d.weekday];
  }

  void _showViewDropdown(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(999, 120, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        _menuItem('Week', true),
        _menuItem('Month', false),
        _menuItem('Year', false),
      ],
    ).then((value) {
      if (value == 'Month') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const CalendarMonthPage()));
      } else if (value == 'Year') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const CalendarYearPage()));
      }
    });
  }

  PopupMenuItem<String> _menuItem(String label, bool active) {
    return PopupMenuItem(
      value: label,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? primaryBlue : Colors.black87,
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    DateTime selectedDate = _focusedDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Event',
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Event title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: primaryBlue, onPrimary: Colors.white),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setD(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: primaryBlue),
                      const SizedBox(width: 8),
                      Text(_fullDate(selectedDate),
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final key = _eventKey(selectedDate);
                  setState(() {
                    _events[key] = [
                      ...(_events[key] ?? []),
                      titleCtrl.text.trim()
                    ];
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_focusedDate);
    final leftDay = _focusedDate;
    final rightDay = _focusedDate.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Hi, ',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: 'Rina',
                          style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.notifications, color: primaryBlue),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Month label + dropdown ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mar 2026',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showViewDropdown(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text('Week',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Week strip ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: weekDays.map((d) {
                    final isSelected = d.day == _focusedDate.day &&
                        d.month == _focusedDate.month;
                    return GestureDetector(
                      onTap: () => setState(() => _focusedDate = d),
                      child: Container(
                        width: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _shortDay(d),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Two-day view ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildDayColumn(leftDay)),
                      Container(width: 1, color: Colors.grey.shade200),
                      Expanded(child: _buildDayColumn(rightDay)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Add Event Button ──
            Center(
              child: GestureDetector(
                onTap: _showAddEventDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    '+ Add event',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDayColumn(DateTime day) {
    final events = _getEvents(day);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fullDate(day),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryBlue),
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            const Text('No Event',
                style: TextStyle(fontSize: 13, color: Colors.grey))
          else
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
          const Text('Event :',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.home, color: Colors.white, size: 30),
          ),
          // Calendar (aktif) — icon history seperti di dashboard
          const Icon(Icons.history, color: Colors.white, size: 30),
          // Chat
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
          // Profile
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}