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

        final key = _eventKey(parsedStart);
        grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(item);
      }

      if (!mounted) return;
      setState(() {
        _events
          ..clear()
          ..addAll(grouped);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat jadwal terbaru.')),
      );
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

  String _prettyDateTime(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '-';

    final hour12 = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final period = parsed.hour < 12 ? 'AM' : 'PM';
    return '${_fullDate(parsed)} • $hour12.$minute $period';
  }

  String _valueOrDash(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty || text.toLowerCase() == 'null' ? '-' : text;
  }

  String _repeatFromApi(String value) {
    final raw = value.trim().toLowerCase();
    if (raw == 'daily') return 'Daily';
    if (raw == 'weekly') return 'Weekly';
    if (raw == 'monthly') return 'Monthly';
    return 'Never';
  }

  Future<void> _openEditEvent(Map<String, dynamic> event) async {
    final id = int.tryParse((event['id'] ?? '').toString()) ?? 0;
    if (id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event tidak valid untuk diedit.')),
      );
      return;
    }

    final startRaw = (event['start_time'] ?? '').toString();
    final endRaw = (event['end_time'] ?? '').toString();
    final startParsed = DateTime.tryParse(startRaw) ?? DateTime.now();
    final endParsed =
        DateTime.tryParse(endRaw) ?? startParsed.add(const Duration(hours: 1));

    final saved = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCalendarPage(
          initialData: {
            'scheduleId': id,
            'title': _valueOrDash(event['title']),
            'notes': _valueOrDash(event['notes']) == '-'
                ? _valueOrDash(event['caption'])
                : _valueOrDash(event['notes']),
            'platform': _valueOrDash(event['platform']),
            'isDaily': event['is_daily'] == true,
            'repeat': _repeatFromApi(_valueOrDash(event['repeat'])),
            'reminder': _valueOrDash(event['reminder_type']),
            'startDate': DateTime(
              startParsed.year,
              startParsed.month,
              startParsed.day,
            ),
            'endDate': DateTime(endParsed.year, endParsed.month, endParsed.day),
            'startTime': TimeOfDay.fromDateTime(startParsed),
            'endTime': TimeOfDay.fromDateTime(endParsed),
          },
        ),
      ),
    );

    if (saved != null) {
      await _loadSchedules();
      final info = (saved['local_reminder_debug'] ?? '').toString();
      if (info.isNotEmpty && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(info)));
      }
    }
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final title = _valueOrDash(event['title']);
    final caption = _valueOrDash(event['caption']);
    final platform = _valueOrDash(event['platform']);
    final startTime = _prettyDateTime(_valueOrDash(event['start_time']));
    final endTime = _prettyDateTime(_valueOrDash(event['end_time']));
    final repeat = _valueOrDash(event['repeat']);
    final reminder = _valueOrDash(event['reminder_type']);
    final notes = _valueOrDash(event['notes']);
    final status = (event['is_posted'] == true) ? 'Posted' : 'Scheduled';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailLine('Platform', platform),
              _detailLine('Status', status),
              _detailLine('Start', startTime),
              _detailLine('End', endTime),
              _detailLine('Repeat', repeat),
              _detailLine('Reminder', reminder),
              _detailLine('Caption', caption),
              _detailLine('Notes', notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _openEditEvent(event);
              });
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CalendarMonthPage()),
          );
        });
      } else if (value == 'Year') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CalendarYearPage()),
          );
        });
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
                    final saved = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCalendarPage(),
                      ),
                    );
                    if (saved != null) {
                      await _loadSchedules();
                      final info = (saved['local_reminder_debug'] ?? '')
                          .toString();
                      if (info.isNotEmpty && mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(info)));
                      }
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
              return _buildDeadlineRow(
                title,
                onTap: () => _showEventDetails(e),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDeadlineRow(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: onTap == null
                ? Colors.white.withOpacity(0.35)
                : const Color(0xFF4A90E2).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF4A90E2), size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.black45,
                ),
            ],
          ),
        ),
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
