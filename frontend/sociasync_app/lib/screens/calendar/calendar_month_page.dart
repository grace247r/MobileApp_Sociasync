import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_year_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/inbox/inbox_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
        );
      } else if (value == 'Year') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarYearPage()),
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

  void _onMonthTapped(int month) {
    final selectedDate = DateTime(currentYear, month, 1);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarWeekPage(initialDate: selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          SafeArea(
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
                            child: const Row(
                              children: [
                                Text(
                                  'Month',
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

                // ── 12 month grid ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      100,
                    ), // Padding bawah untuk Navbar
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.4,
                        ), // Glassmorphism style
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
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
              ],
            ),
          ),

          // ── App Navbar Melayang ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: 0, // Bagian dari Home/Calendar
              backgroundColor: primaryBlue,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                  );
                }
                if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const InboxPage()),
                  );
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

  Widget _buildMiniMonth(int month, int year) {
    const monthNames = [
      '',
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    final isCurrentMonth = month == currentMonth;

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int startOffset = firstDay.weekday % 7;

    final bgColor = isCurrentMonth
        ? primaryBlue
        : Colors.white.withOpacity(0.6);
    final textColor = isCurrentMonth ? Colors.white : Colors.black87;
    final headerColor = isCurrentMonth ? Colors.white : primaryBlue;
    final dayNumColor = isCurrentMonth ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () => _onMonthTapped(month),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isCurrentMonth
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Text(
              monthNames[month],
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (d) => SizedBox(
                      width: 14,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: dayNumColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      style: TextStyle(fontSize: 6.5, color: textColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
