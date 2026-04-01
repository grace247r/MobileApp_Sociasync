import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_year_page.dart';

class CalendarMonthPage extends StatefulWidget {
  const CalendarMonthPage({super.key});

  @override
  State<CalendarMonthPage> createState() => _CalendarMonthPageState();
}

class _CalendarMonthPageState extends State<CalendarMonthPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int currentYear = 2026;
  final int currentMonth = 3; // March highlighted

  void _showViewDropdown(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(999, 120, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        _menuItem('Week', false),
        _menuItem('Month', true),
        _menuItem('Year', false),
      ],
    ).then((value) {
      if (value == 'Week') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const CalendarWeekPage()));
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

  @override
  Widget build(BuildContext context) {
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

            // ── Year label + dropdown ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currentYear',
                    style: const TextStyle(
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

            // ── 12 month grid ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 12,
                    itemBuilder: (_, i) =>
                        _buildMiniMonth(i + 1, currentYear),
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

  Widget _buildMiniMonth(int month, int year) {
    const monthNames = [
      '', 'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    final isCurrentMonth = month == currentMonth;

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // weekday: Mon=1 ... Sun=7; offset for Sunday-first grid
    int startOffset = firstDay.weekday % 7; // Sun=0

    final bgColor =
        isCurrentMonth ? primaryBlue : const Color(0xFFEAEFF8);
    final textColor = isCurrentMonth ? Colors.white : Colors.black87;
    final headerColor = isCurrentMonth ? Colors.white : primaryBlue;
    final dayNumColor =
        isCurrentMonth ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          // Month name
          Text(
            monthNames[month],
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
          const SizedBox(height: 3),
          // Day headers S M T W T F S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 14,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                              color: dayNumColor)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 2),
          // Day grid
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (_, idx) {
                if (idx < startOffset) return const SizedBox();
                final day = idx - startOffset + 1;
                return Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                        fontSize: 6.5, color: textColor),
                  ),
                );
              },
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.home, color: Colors.white, size: 30),
          ),
          const Icon(Icons.calendar_today,
              color: Colors.white, size: 26),
          const Icon(Icons.chat_bubble_outline,
              color: Colors.white, size: 30),
          const Icon(Icons.person_outline,
              color: Colors.white, size: 30),
        ],
      ),
    );
  }
}