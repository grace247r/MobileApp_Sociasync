import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/add_calendar_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_month_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_year_page.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/services/schedule_service.dart';

class CalendarWeekPage extends StatefulWidget {
  final DateTime? initialDate;
  const CalendarWeekPage({super.key, this.initialDate});

  @override
  State<CalendarWeekPage> createState() => _CalendarWeekPageState();
}

class _CalendarWeekPageState extends State<CalendarWeekPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final Color lightBlueBorder = const Color(0xFFBDD7EE);
  late DateTime _focusedDate;

  final Map<String, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate ?? DateTime.now();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await ScheduleService.getSchedules();
      final grouped = <String, List<Map<String, dynamic>>>{};

      for (final item in schedules) {
        final rawStart = (item['start_time'] ?? '').toString();
        final parsedStart = DateTime.tryParse(rawStart);
        if (parsedStart == null) continue;

        final key = _eventKey(parsedStart.toLocal());
        grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(item);
      }

      if (!mounted) return;
      setState(() {
        _events
          ..clear()
          ..addAll(grouped);
      });
    } catch (_) {
      // Keep UI usable even when API fails.
    }
  }

  // --- Logic Helpers ---
  List<DateTime> _getWeekDays(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(9, (i) => monday.add(Duration(days: i)));
  }

  String _eventKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]} ${d.year}';
  }

  String _fullDate(DateTime d) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }

  List<Map<String, dynamic>> _eventsForDay(DateTime day) {
    return _events[_eventKey(day)] ?? const <Map<String, dynamic>>[];
  }

  // --- Navigasi Dropdown ---
  void _showViewDropdown(BuildContext anchorContext) {
    final RenderBox button = anchorContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(anchorContext).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: anchorContext,
      position: position.shift(const Offset(0, 45)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        const PopupMenuItem(
          value: 'Week',
          child: Text('Week', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const PopupMenuItem(value: 'Month', child: Text('Month')),
        const PopupMenuItem(value: 'Year', child: Text('Year')),
      ],
    ).then((value) {
      if (!mounted) return;
      if (value == 'Month') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CalendarMonthPage()),
        );
      } else if (value == 'Year') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CalendarYearPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_focusedDate);
    final leftDay = _focusedDate;
    final rightDay = _focusedDate.add(const Duration(days: 1));

    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (User: Rina)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Month & Switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _monthLabel(_focusedDate),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => _showViewDropdown(ctx),
                        child: _buildViewDropdownBtn(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Container Utama (Simetris)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF82B0E7), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        // Strip Hari (Mo, Tu, ...)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 5,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: weekDays
                                  .map((d) => _buildWeekDayItem(d))
                                  .toList(),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: Color(0xFFBDD7EE),
                          thickness: 1.5,
                        ),

                        // Kolom Hari (Kiri & Kanan)
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildDayColumn(leftDay)),
                              Container(width: 1.5, color: lightBlueBorder),
                              Expanded(child: _buildDayColumn(rightDay)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Button Add Event
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCalendarPage(),
                      ),
                    );
                    if (created == true) {
                      await _loadSchedules();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '+ Add event',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: 1,
          backgroundColor: primaryBlue,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            } else if (index == 1) {
              return;
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotPage()),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeekDayItem(DateTime d) {
    final isSelected =
        d.day == _focusedDate.day && d.month == _focusedDate.month;
    const days = ['', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su', 'Mo', 'Tu'];

    return GestureDetector(
      onTap: () => setState(() => _focusedDate = d),
      child: Container(
        width: 42,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Hapus decoration dari sini agar background hari tidak ikut biru
        color: Colors.transparent,
        child: Column(
          children: [
            // Tulisan Hari (Mo, Tu, dll)
            Text(
              days[d.weekday],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            // Bungkus Angka Tanggal dengan Container untuk warna seleksi
            Container(
              width: 30, // Atur lebar lingkaran/kotak tanggal
              height: 30, // Atur tinggi lingkaran/kotak tanggal
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Warna biru hanya muncul di sini jika isSelected true
                color: isSelected
                    ? const Color(0xFF8EBAE3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8), // Buat kotak agak bulat
              ),
              child: Text(
                '${d.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  // Teks jadi putih kalau dipilih
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime day) {
    final events = _eventsForDay(day);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _fullDate(day),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Deadline/Event list dari API schedules
          if (events.isEmpty) ...[
            _buildDeadlineRow('Belum ada event'),
          ] else ...[
            ...events.take(4).map((e) {
              final title = (e['title'] ?? 'Untitled event').toString();
              return _buildDeadlineRow(title);
            }),
          ],

          const Spacer(),
          const Text(
            'Event :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Ringkasan event harian
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1D5093).withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(10),
              child: events.isEmpty
                  ? const Center(
                      child: Text(
                        'No event',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (_, i) {
                        final title = (events[i]['title'] ?? 'Untitled event')
                            .toString();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• $title',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineRow(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Color(0xFF4A90E2), size: 12),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildViewDropdownBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2B65AD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Text(
            'Week',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }
}
