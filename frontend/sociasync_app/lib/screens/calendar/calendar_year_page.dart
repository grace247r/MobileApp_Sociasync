import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_month_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart'; // Import Header
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class CalendarYearPage extends StatefulWidget {
  const CalendarYearPage({super.key});

  @override
  State<CalendarYearPage> createState() => _CalendarYearPageState();
}

class _CalendarYearPageState extends State<CalendarYearPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int currentYear = 2026;
  int? expandedYear;

  final List<int> years = [2020, 2021, 2022, 2023, 2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
    expandedYear = currentYear;
  }

  // --- Navigasi View ---
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

  // --- Logika Klik Bulan ---
  void _navigateToMonth(int year, int monthIndex) {
    // monthIndex 1 = Jan, 2 = Feb, dst.
    final selectedDate = DateTime(year, monthIndex, 1);
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
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Dashboard Header (Biar konsisten ada notif & nama Rina)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: DashboardHeader(
                      primaryColor: primaryBlue,
                      onNotificationTap: () {},
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Title & View Dropdown
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

                  // 3. Year list
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
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
                                  // Baris Tahun
                                  InkWell(
                                    onTap: () => setState(
                                      () => expandedYear = isExpanded
                                          ? null
                                          : year,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrentYear
                                            ? primaryBlue
                                            : (isExpanded
                                                  ? Colors.white.withOpacity(
                                                      0.3,
                                                    )
                                                  : Colors.transparent),
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

                                  // Grid Bulan (Hanya muncul jika di-expand)
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
                                          : Colors.white.withOpacity(0.3),
                                      child: Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        alignment: WrapAlignment.start,
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
                                            ].asMap().entries.map((entry) {
                                              int idx =
                                                  entry.key + 1; // Bulan 1-12
                                              String monthName = entry.value;

                                              return GestureDetector(
                                                onTap: () =>
                                                    _navigateToMonth(year, idx),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
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
                                                    monthName,
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
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  if (year != years.last)
                                    Divider(
                                      height: 1,
                                      color: Colors.grey.withOpacity(0.1),
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

            // 4. App Navbar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: 1, // Tab Calendar
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
          ],
        ),
      ),
    );
  }
}
