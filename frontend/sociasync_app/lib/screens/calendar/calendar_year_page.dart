import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_month_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/inbox/inbox_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class CalendarYearPage extends StatefulWidget {
  const CalendarYearPage({super.key});

  @override
  State<CalendarYearPage> createState() => _CalendarYearPageState();
}

class _CalendarYearPageState extends State<CalendarYearPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  final int currentYear = 2026;
  int? expandedYear; // row tahun yang sedang dibuka

  final List<int> years = [2020, 2021, 2022, 2023, 2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
    expandedYear = currentYear; // Default ekspansi ke 2026
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

                // ── Title & View Dropdown ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Yearly Calendar',
                        style: TextStyle(
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
                                  'Year',
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      100,
                    ), // Padding untuk Navbar
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: years.map((year) {
                            final isExpanded = expandedYear == year;
                            final isCurrentYear = year == currentYear;

                            return Column(
                              children: [
                                // Year Row
                                InkWell(
                                  onTap: () => setState(() {
                                    expandedYear = isExpanded ? null : year;
                                  }),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrentYear
                                          ? primaryBlue
                                          : isExpanded
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$year',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                isExpanded || isCurrentYear
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isCurrentYear
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: isCurrentYear
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Months Grid (Expanded)
                                if (isExpanded)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      20,
                                    ),
                                    color: isCurrentYear
                                        ? primaryBlue
                                        : Colors.white.withOpacity(0.5),
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 10,
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
                                                (m) => Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isCurrentYear
                                                        ? Colors.white
                                                              .withOpacity(0.2)
                                                        : primaryBlue
                                                              .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    m,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isCurrentYear
                                                          ? Colors.white
                                                          : primaryBlue,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),

                                if (year != years.last)
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── App Navbar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: 0,
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
}
