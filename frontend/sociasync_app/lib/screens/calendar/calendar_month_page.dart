import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_year_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart'; // Import DashboardHeader
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
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
      child: Scaffold(
        backgroundColor: Colors.transparent, // Agar background wrapper terlihat
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Gunakan DashboardHeader agar seragam)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: DashboardHeader(
                      userName: 'Rina',
                      primaryColor: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Year label + dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currentYear',
                          style: const TextStyle(
                            fontSize: 24,
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

                  // 3. Grid 12 Bulan dalam Kontainer Glassmorphism
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallPhone = constraints.maxWidth < 340;
                            final crossAxisCount = isSmallPhone ? 2 : 3;
                            final spacing = isSmallPhone ? 8.0 : 10.0;
                            final itemWidth =
                                (constraints.maxWidth -
                                    ((crossAxisCount - 1) * spacing)) /
                                crossAxisCount;
                            final childAspectRatio = itemWidth < 115
                                ? 0.95
                                : 0.82;

                            return GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: childAspectRatio,
                                  ),
                              itemCount: 12,
                              itemBuilder: (_, i) =>
                                  _buildMiniMonth(i + 1, currentYear),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: 1, // Fokus pada tab Calendar
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
                MaterialPageRoute(builder: (_) => const ChatbotPage()),
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
        : Colors.white.withOpacity(0.8);
    final textColor = isCurrentMonth ? Colors.white : Colors.black87;
    final headerColor = isCurrentMonth ? Colors.white : primaryBlue;
    final dayNumColor = isCurrentMonth ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () => _onMonthTapped(month),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortest = constraints.biggest.shortestSide;
            final horizontalPadding = (shortest * 0.06)
                .clamp(4.0, 8.0)
                .toDouble();
            final verticalPadding = (shortest * 0.05)
                .clamp(4.0, 7.0)
                .toDouble();
            final monthFontSize = (shortest * 0.09).clamp(8.0, 11.0).toDouble();
            final weekDayFontSize = (shortest * 0.07)
                .clamp(6.0, 9.0)
                .toDouble();
            final dayFontSize = (shortest * 0.075).clamp(6.0, 9.5).toDouble();

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      monthNames[month],
                      style: TextStyle(
                        fontSize: monthFontSize,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: (shortest * 0.03).clamp(2.0, 5.0).toDouble(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (d) => Expanded(
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: weekDayFontSize,
                                fontWeight: FontWeight.bold,
                                color: dayNumColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(
                    height: (shortest * 0.02).clamp(1.0, 3.0).toDouble(),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: dayFontSize,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
