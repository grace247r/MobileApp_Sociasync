import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_month_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class CalendarYearPage extends StatefulWidget {
  const CalendarYearPage({super.key});

  @override
  State<CalendarYearPage> createState() => _CalendarYearPageState();
}

class _CalendarYearPageState extends State<CalendarYearPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  final int currentYear = 2026;
  int? expandedYear; // which year row is expanded to show months

  final List<int> years = [2020, 2021, 2022, 2023, 2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
    expandedYear = currentYear; // 2026 expanded by default
  }

  void _showViewDropdown(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(999, 120, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        _menuItem('Week', false),
        _menuItem('Month', false),
        _menuItem('Year', true),
      ],
    ).then((value) {
      if (value == 'Week') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
        );
      } else if (value == 'Month') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarMonthPage()),
        );
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
                      color: Colors.black87,
                    ),
                  ),
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showViewDropdown(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Week',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Year list ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: years.map((year) {
                      final isExpanded = expandedYear == year;
                      final isCurrentYear = year == currentYear;

                      return Column(
                        children: [
                          // Year row
                          InkWell(
                            onTap: () => setState(() {
                              expandedYear = isExpanded ? null : year;
                            }),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentYear
                                    ? primaryBlue
                                    : isExpanded
                                    ? const Color(0xFFDDE8F5)
                                    : Colors.transparent,
                                borderRadius: isExpanded && !isCurrentYear
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                      )
                                    : null,
                              ),
                              child: Text(
                                '$year',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isExpanded || isCurrentYear
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrentYear
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),

                          // Months row (expanded)
                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              color: isCurrentYear
                                  ? primaryBlue
                                  : const Color(0xFFDDE8F5),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children:
                                    [
                                          'JAN',
                                          'FEB',
                                          'MAR',
                                          'APR',
                                          'MAY',
                                          'JUN',
                                          'JUL',
                                          'AUG',
                                          'SEP',
                                          'OKT',
                                          'NOV',
                                          'DEC',
                                        ]
                                        .map(
                                          (m) => Text(
                                            m,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isCurrentYear
                                                  ? Colors.white
                                                  : primaryBlue,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),

                          if (year != years.last)
                            Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              indent: 0,
                            ),
                        ],
                      );
                    }).toList(),
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
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
            ),
            child: const Icon(Icons.history, color: Colors.white, size: 30),
          ),
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
