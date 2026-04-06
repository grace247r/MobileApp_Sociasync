import 'package:flutter/material.dart';

class AddCalendarPage extends StatefulWidget {
  /// Jika diisi, halaman berjalan dalam mode Edit
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

  String _formatDate(DateTime d) {
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
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
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme:
              ColorScheme.light(primary: primaryBlue, onPrimary: Colors.white),
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
          colorScheme:
              ColorScheme.light(primary: primaryBlue, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startTime = picked;
        else endTime = picked;
      });
    }
  }

  void _showPickerDialog(String title, List<String> options, String current,
      ValueChanged<String> onSelect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
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
                title: Text(options[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryBlue : Colors.black87,
                    )),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _submitEvent() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an event title'),
          backgroundColor: primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                          fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: 'Rina',
                          style: TextStyle(
                              color: primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.notifications, color: primaryBlue),
                ],
              ),
            ),

            // ── Back + Title (Add / Edit) ──
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
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),

            // ── Form ──
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_titleCtrl, 'Title...'),
                    const SizedBox(height: 10),
                    _buildTextField(_locationCtrl, 'Location...'),
                    const SizedBox(height: 16),
                    _buildScheduleGroup(),
                    const SizedBox(height: 12),
                    _buildOptionTile('Repeat', repeat,
                        onTap: () => _showPickerDialog(
                            'Repeat', repeatOptions, repeat,
                            (v) => setState(() => repeat = v))),
                    const SizedBox(height: 10),
                    _buildOptionTile('Reminder', reminder,
                        onTap: () => _showPickerDialog(
                            'Reminder', reminderOptions, reminder,
                            (v) => setState(() => reminder = v))),
                    const SizedBox(height: 12),
                    const Text('Notes',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    _buildNotesField(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Submit Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 2,
                  ),
                  child: Text(
                    _isEditMode ? 'Update Event' : '+ Add event',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildScheduleGroup() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FB),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Daily',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ),
              Switch(
                value: isDaily,
                onChanged: (v) => setState(() => isDaily = v),
                activeColor: Colors.white,
                activeTrackColor: primaryBlue,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          Divider(height: 8, color: Colors.grey.shade300),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                  width: 48,
                  child: Text('Start',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87))),
              const SizedBox(width: 6),
              _chip(_formatDate(startDate), onTap: () => _pickDate(true)),
              const SizedBox(width: 8),
              _chip(_formatTime(startTime), onTap: () => _pickTime(true)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                  width: 48,
                  child: Text('End',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87))),
              const SizedBox(width: 6),
              _chip(_formatDate(endDate), onTap: () => _pickDate(false)),
              const SizedBox(width: 8),
              _chip(_formatTime(endTime), onTap: () => _pickTime(false)),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _chip(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildOptionTile(String label, String value,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
            ),
            Text(value,
                style:
                    const TextStyle(fontSize: 14, color: Colors.black45)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _notesCtrl,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Write your notes here...',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.home, color: Colors.white, size: 30),
          ),
          const Icon(Icons.history, color: Colors.white, size: 30),
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
          const Icon(Icons.person_outline, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}