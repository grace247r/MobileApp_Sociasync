import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
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
    '5 mins before',
    '10 mins before',
    '1 hour before',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _titleCtrl = TextEditingController(text: d?['title'] ?? '');
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
    _notesCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? startDate : endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart)
          startTime = picked;
        else
          endTime = picked;
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
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) => ListTile(
              title: Text(options[i]),
              trailing: options[i] == current
                  ? Icon(Icons.check, color: primaryBlue)
                  : null,
              onTap: () {
                onSelect(options[i]);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIC SUBMIT ---
  void _submitEvent() {
    if (_titleCtrl.text.isEmpty) return;

    // Data dikirim balik ke CalendarWeekPage
    Navigator.pop(context, {
      'title': _titleCtrl.text,
      'notes': _notesCtrl.text,
      'isDaily': isDaily,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'repeat': repeat,
      'reminder': reminder,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: DashboardHeader(
                      userName: 'Rina',
                      primaryColor: primaryBlue,
                      onNotificationTap: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: primaryBlue,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          _isEditMode ? 'Edit Event' : 'Add Event',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(_titleCtrl, 'Title...'),
                          const SizedBox(height: 16),
                          _buildScheduleGroup(),
                          const SizedBox(height: 16),
                          _buildOptionTile(
                            'Repeat',
                            repeat,
                            onTap: () {
                              _showPickerDialog(
                                'Repeat',
                                repeatOptions,
                                repeat,
                                (v) => setState(() => repeat = v),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildOptionTile(
                            'Reminder',
                            reminder,
                            onTap: () {
                              _showPickerDialog(
                                'Reminder',
                                reminderOptions,
                                reminder,
                                (v) => setState(() => reminder = v),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildNotesField(),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitEvent, // Pakai logic submit
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 14,
                                ),
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: 1,
                backgroundColor: primaryBlue,
                onTap: (index) {
                  if (index == 0)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  if (index == 2)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const InboxPage()),
                    );
                  if (index == 3)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDCE3FF).withOpacity(0.66),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF1D2F73),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleGroup() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE3FF).withOpacity(0.66),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2f73),
                ),
              ),
              Switch(
                value: isDaily,
                onChanged: (v) => setState(() => isDaily = v),
                activeThumbColor: primaryBlue,
              ),
            ],
          ),
          // LOGIC: Start & End otomatis hilang/off jika isDaily aktif
          if (!isDaily) ...[
            const Divider(height: 20),
            _buildTimeRow('Start', startDate, startTime, true),
            const SizedBox(height: 12),
            _buildTimeRow('End', endDate, endTime, false),
          ],
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2f73),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _timeChip(_formatDate(date), onTap: () => _pickDate(isStart)),
              const SizedBox(width: 8),
              _timeChip(_formatTime(time), onTap: () => _pickTime(isStart)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeChip(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFDCE3FF).withOpacity(0.66),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2f73),
              ),
            ),
            Row(
              children: [
                Text(value, style: const TextStyle(color: Colors.black45)),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFDCE3FF).withOpacity(0.66),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _notesCtrl,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: 'Notes',
          labelStyle: TextStyle(
            color: Color(0xFF1D5093),
            fontWeight: FontWeight.bold,
          ),
          alignLabelWithHint: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
