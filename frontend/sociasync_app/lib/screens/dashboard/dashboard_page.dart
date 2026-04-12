import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/content_generator/content_generator_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/analytics/monthly_summary_page.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sociasync_app/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 0;
  String _userName = 'User';
  int _unreadCount = 0;

  final PageController _statsPageController = PageController();
  int _activeStatsPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUnreadCount();
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await AuthService.getMe();
      if (!mounted) return;
      final name = (profile['name'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        setState(() => _userName = name);
      }
    } catch (_) {
      // Keep fallback name if profile cannot be loaded.
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await AuthService.getUnreadNotificationCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Keep default value if unread count cannot be loaded.
    }
  }

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
      );
    } else if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatbotPage()));
    } else if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  void dispose() {
    _statsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  DashboardHeader(
                    userName: _userName,
                    primaryColor: primaryBlue,
                    unreadCount: _unreadCount,
                    onNotificationTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                      if (!mounted) return;
                      _loadUnreadCount();
                    },
                  ),
                  const SizedBox(height: 15),

                  // --- SLIDABLE STATS GRID (FIXED: TIDAK KEPOTONG) ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7CD9).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          // Tambah tinggi agar row kedua stats tidak kepotong.
                          height: 290,
                          child: PageView(
                            controller: _statsPageController,
                            onPageChanged: (int page) {
                              setState(() => _activeStatsPage = page);
                            },
                            children: [
                              _buildStatsPageContent('Instagram @rina_style'),
                              _buildStatsPageContent('TikTok @rina_creative'),
                            ],
                          ),
                        ),
                        // Page Indicator
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              2,
                              (index) =>
                                  _buildIndicator(index == _activeStatsPage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- WEEKLY CHART SECTION ---
                  _buildSectionHeader('Weekly Performance', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MonthlySummaryPage(),
                      ),
                    );
                  }),
                  const SizedBox(height: 15),
                  _buildSmoothChartCard(),

                  const SizedBox(height: 30),

                  // --- BEST PERFORMING POST SECTION ---
                  _buildSectionHeader('Best Performing Post', null),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPostItem(),
                        _buildPostItem(),
                        _buildPostItem(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- GENERATE BUTTON ---
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ContentGeneratorPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '+ Generate',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NAVBAR
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: _currentIndex,
                backgroundColor: primaryBlue,
                onTap: _onNavbarTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPageContent(String accountName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accountName,
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent:
                    98, // Tinggi tetap supaya isi kartu tidak overflow
              ),
              children: [
                _buildStatCard('4.8%', 'Engagement'),
                _buildStatCard('45.7 K', 'Reach'),
                _buildStatCard('12.9 K', 'Followers'),
                _buildStatCard('24', 'Post'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmoothChartCard() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2E7CD9).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 15, 10),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                    final index = value.toInt();
                    if (value != index.toDouble() ||
                        index < 0 ||
                        index >= days.length) {
                      return const Text('');
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          color: Color(0xFF123B74),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    if (value % 20 != 0) return const Text('');
                    return Text(
                      '${value.toInt()}K',
                      style: const TextStyle(
                        color: Color(0xFF123B74),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 60,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 42),
                  const FlSpot(1, 35),
                  const FlSpot(2, 38),
                  const FlSpot(3, 56),
                  const FlSpot(4, 53),
                  const FlSpot(5, 54),
                  const FlSpot(6, 58),
                ],
                isCurved: true,
                color: const Color(0xFF2568B8),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2568B8).withOpacity(0.3),
                      const Color(0xFF2568B8).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          if (onTap != null) Icon(Icons.chevron_right, color: primaryBlue),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 22 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem() {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Icon(Icons.image, color: Colors.white, size: 30),
      ),
    );
  }
}
