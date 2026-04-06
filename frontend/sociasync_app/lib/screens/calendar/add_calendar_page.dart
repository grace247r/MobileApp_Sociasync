import 'package:flutter/material.dart';
// Pastikan path import di bawah ini sesuai dengan folder di project kamu
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/inbox/inbox_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class AddCalendarPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddCalendarPage({super.key, this.initialData});

  @override
  State<AddCalendarPage> createState() => _AddCalendarPageState();
}

class _AddCalendarPageState extends State<AddCalendarPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;

  late bool isDaily;
  late DateTime startDate;
  late TimeOfDay startTime;
  late DateTime endDate;
  late TimeOfDay endTime;
  late String repeat;
  late String reminder;

  bool get _isEditMode => widget.initialData != null;

  final repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];
  final reminderOptions = [
    'Never',
    '5 minutes before',
    '10 minutes before',
    '30 minutes before',
    '1 hour before',
    '1 day before',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _titleCtrl = TextEditingController(text: d?['title'] ?? '');
    _locationCtrl = TextEditingController(text: d?['location'] ?? '');
    _notesCtrl = TextEditingController(text: d?['notes'] ?? '');
    isDaily = d?['isDaily'] ?? false;
    startDate = d?['startDate'] ?? DateTime.now();
    endDate = d?['endDate'] ?? DateTime.now();
    startTime = d?['startTime'] ?? const TimeOfDay(hour: 10, minute: 0);
    endTime = d?['endTime'] ?? const TimeOfDay(hour: 12, minute: 0);
    repeat = d?['repeat'] ?? 'Never';
    reminder = d?['reminder'] ?? 'Never';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // --- Helper Formatter ---
  String _formatDate(DateTime d) {
    const months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour.$m $period';
  }

  // --- Pickers ---
  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? startDate : endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryBlue,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate.isBefore(startDate)) endDate = startDate;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? startTime : endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryBlue,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _showPickerDialog(
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelect,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              final isSelected = options[i] == current;
              return ListTile(
                dense: true,
                title: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? primaryBlue : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: primaryBlue, size: 18)
                    : null,
                onTap: () {
                  onSelect(options[i]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _submitEvent() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return; // Tambahkan snackbar jika perlu
    Navigator.pop(context, {
      'title': title,
      'location': _locationCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'repeat': repeat,
      'reminder': reminder,
      'isDaily': isDaily,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
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
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Rina',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.notifications, color: primaryBlue),
                    ],
                  ),
                ),

                // ── Back + Title ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: primaryBlue),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        _isEditMode ? 'Edit Event' : 'Add Event',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form Content ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      120,
                    ), // Padding bawah untuk Navbar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(_titleCtrl, 'Title...'),
                        const SizedBox(height: 10),
                        _buildTextField(_locationCtrl, 'Location...'),
                        const SizedBox(height: 16),
                        _buildScheduleGroup(),
                        const SizedBox(height: 12),
                        _buildOptionTile(
                          'Repeat',
                          repeat,
                          onTap: () => _showPickerDialog(
                            'Repeat',
                            repeatOptions,
                            repeat,
                            (v) => setState(() => repeat = v),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildOptionTile(
                          'Reminder',
                          reminder,
                          onTap: () => _showPickerDialog(
                            'Reminder',
                            reminderOptions,
                            reminder,
                            (v) => setState(() => reminder = v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildNotesField(),
                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitEvent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _isEditMode ? 'Update Event' : '+ Add event',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── App Navbar Melayang ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: 1,
              backgroundColor: primaryBlue,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                  );
                  return;
                }

                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
                  );
                  return;
                }

                if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const InboxPage()),
                  );
                  return;
                }

                if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Switch(
                value: isDaily,
                onChanged: (v) => setState(() => isDaily = v),
                activeThumbColor: primaryBlue,
              ),
            ],
          ),
          const Divider(),
          _buildTimeRow('Start', startDate, startTime, true),
          const SizedBox(height: 10),
          _buildTimeRow('End', endDate, endTime, false),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    String label,
    DateTime date,
    TimeOfDay time,
    bool isStart,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _chip(_formatDate(date), onTap: () => _pickDate(isStart)),
        const SizedBox(width: 8),
        _chip(_formatTime(time), onTap: () => _pickTime(isStart)),
      ],
    );
  }

  Widget _chip(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(value, style: const TextStyle(color: Colors.black45)),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _notesCtrl,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Write notes here...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
