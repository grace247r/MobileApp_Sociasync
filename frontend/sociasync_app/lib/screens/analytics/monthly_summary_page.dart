import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/dashboard/instagram_connect_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'package:sociasync_app/services/instagram_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/date_range_picker_dialog.dart'
    as date_picker;

class MonthlySummaryPage extends StatefulWidget {
  const MonthlySummaryPage({super.key});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 1;

  String _userName = 'User';
  bool _isLoading = true;
  String? _errorMessage;
  bool _connected = false;
  String _username = '';

  Map<String, dynamic>? _latestStats;
  List<Map<String, dynamic>> _history = const <Map<String, dynamic>>[];

  DateTime _startDate = DateTime(2026, 1, 1);
  DateTime _endDate = DateTime(2026, 7, 31);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadUserName(), _loadAnalyticsData(showLoader: true)]);
  }

  Future<void> _loadUserName() async {
    try {
      final me = await AuthService.getMe();
      if (!mounted) return;
      final name = (me['name'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        setState(() => _userName = name);
      }
    } catch (_) {
      // Keep fallback name.
    }
  }

  Future<void> _loadAnalyticsData({bool showLoader = false}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final dashboard = await InstagramService.getDashboard();
      final connected = dashboard['instagram_connected'] == true;
      final username = (dashboard['instagram_username'] ?? '').toString();
      final latestStats = dashboard['latest_stats'] is Map
          ? Map<String, dynamic>.from(dashboard['latest_stats'] as Map)
          : null;

      List<Map<String, dynamic>> history = const <Map<String, dynamic>>[];
      if (connected) {
        history = await InstagramService.getStatsHistory(
          limit: 120,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (!mounted) return;
      setState(() {
        _connected = connected;
        _username = username;
        _latestStats = latestStats;
        _history = history.reversed.toList();
        _errorMessage = null;
      });
    } on InstagramServiceException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal memuat analytics Instagram.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateRange() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return date_picker.CustomDateRangeDialog(
          primaryColor: primaryBlue,
          initialStartDate: _startDate,
          initialEndDate: _endDate,
          onApply: (startDate, endDate) async {
            if (!mounted) return;

            final normalizedStart = startDate.isBefore(endDate)
                ? startDate
                : endDate;
            final normalizedEnd = endDate.isAfter(startDate)
                ? endDate
                : startDate;

            setState(() {
              _startDate = normalizedStart;
              _endDate = normalizedEnd;
            });
            await _loadAnalyticsData(showLoader: true);
          },
        );
      },
    );
  }

  void _onNavbarTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatbotPage()));
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    userName: _userName,
                    primaryColor: primaryBlue,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Monthly Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildChartCard(),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDateRangeLabel(_startDate, _endDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildStatsGrid(),
                  const SizedBox(height: 30),

                  const Text(
                    'More Insight',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildInsightCard(
                    'AI Suggestion',
                    'Try AI',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatbotPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: _currentIndex,
          onTap: _onNavbarTap,
          backgroundColor: primaryBlue,
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    if (_isLoading) {
      return _buildMessageCard(
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
      );
    }

    if (_errorMessage != null) {
      return _buildMessageCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF4D5E7C)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadAnalyticsData(showLoader: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (!_connected) {
      return _buildMessageCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instagram belum terhubung.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D5093),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hubungkan username dulu supaya data analytics bisa ditampilkan.',
              style: TextStyle(color: Color(0xFF4D5E7C)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const InstagramConnectPage(),
                  ),
                );
              },
              child: const Text('Connect Username'),
            ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return _buildMessageCard(
        child: const Text(
          'Belum ada history statistik pada rentang tanggal ini.',
          style: TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    final chartSpots = <FlSpot>[];
    final labels = <String>[];
    var maxY = 10.0;

    final groupedByMonth = <String, List<Map<String, dynamic>>>{};
    for (final item in _history) {
      final date = DateTime.tryParse((item['recorded_at'] ?? '').toString());
      if (date == null) continue;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      groupedByMonth.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(item);
    }

    final monthKeys = groupedByMonth.keys.toList()..sort();

    if (monthKeys.length == 1) {
      final onlyKey = monthKeys.first;
      final onlyMonthItems = groupedByMonth[onlyKey]!;
      final onlyMonthLatest = onlyMonthItems.last;
      final fallbackReach = _estimatedReachFromStats(onlyMonthLatest);

      final months = <DateTime>[];
      final startMonth = DateTime(_startDate.year, _startDate.month, 1);
      final endMonth = DateTime(_endDate.year, _endDate.month, 1);
      var cursor = startMonth;
      while (!cursor.isAfter(endMonth)) {
        months.add(cursor);
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }

      if (months.length > 1) {
        for (var i = 0; i < months.length; i++) {
          final monthDate = months[i];
          labels.add(_shortMonthLabel(monthDate));
          final y = fallbackReach / 1000.0;
          chartSpots.add(FlSpot(i.toDouble(), y));
          if (y > maxY) {
            maxY = y;
          }
        }
      }
    }

    if (chartSpots.isEmpty) {
      for (var i = 0; i < monthKeys.length; i++) {
        final key = monthKeys[i];
        final monthlyItems = groupedByMonth[key]!;
        final latestItemOfMonth = monthlyItems.last;
        final reach = _estimatedReachFromStats(latestItemOfMonth);
        final y = reach / 1000.0;
        chartSpots.add(FlSpot(i.toDouble(), y));
        if (y > maxY) {
          maxY = y;
        }

        final monthDate = DateTime.tryParse('$key-01');
        labels.add(_shortMonthLabel(monthDate));
      }
    }

    if (chartSpots.isEmpty) {
      return _buildMessageCard(
        child: const Text(
          'Belum ada data valid untuk ditampilkan pada chart bulanan.',
          style: TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    final chartMaxY = math.max(5.0, maxY + math.max(4.0, maxY * 0.08));
    final yInterval = _adaptiveChartInterval(chartMaxY);
    final xLabelStep = _adaptiveLabelStep(labels.length);
    final maxX = chartSpots.length > 1
        ? (chartSpots.length - 1).toDouble()
        : 1.0;

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.20),
        borderRadius: BorderRadius.circular(10),
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
                    final index = value.toInt();
                    if (value != index.toDouble() ||
                        index < 0 ||
                        index >= labels.length ||
                        index % xLabelStep != 0) {
                      return const Text('');
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[index],
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
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value > chartMaxY - 0.1) {
                      return const Text('');
                    }
                    final steps = value / yInterval;
                    if ((steps - steps.roundToDouble()).abs() > 0.001) {
                      return const Text('');
                    }
                    return Text(
                      _formatChartYAxis(value),
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
            maxX: maxX,
            minY: 0,
            maxY: chartMaxY,
            lineBarsData: [
              LineChartBarData(
                spots: chartSpots,
                isCurved: chartSpots.length > 1,
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

  Widget _buildStatsGrid() {
    final data = _latestStats ?? <String, dynamic>{};
    final referenceStats = _history.isNotEmpty ? _history.last : data;
    final reach = _estimatedReachFromStats(referenceStats);

    final cards = <Map<String, String>>[
      {
        'value':
            '${_asDouble(data['engagement_percentage']).toStringAsFixed(0)}%',
        'label': 'Engagement',
      },
      {'value': _formatCompact(reach), 'label': 'Reach'},
      {
        'value': _formatCompact(_asInt(data['followers_count'])),
        'label': 'Followers',
      },
      {'value': _formatCompact(_asInt(data['total_posts'])), 'label': 'Post'},
    ];

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
          final childAspectRatio = constraints.maxWidth > 600 ? 1.7 : 1.5;

          return GridView.builder(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _buildStatCard(card['value']!, card['label']!);
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B67C0),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF535353),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String btnLabel, {
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF535353),
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(
              btnLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRangeLabel(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Jan - Jul 2026';
    }

    final startMonth = _getMonthName(start.month);
    final endMonth = _getMonthName(end.month);
    if (start.year == end.year) {
      return '$startMonth - $endMonth ${end.year}';
    }
    return '$startMonth ${start.year} - $endMonth ${end.year}';
  }

  String _getMonthName(int? month) {
    if (month == null || month < 1 || month > 12) {
      return 'Jan';
    }

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  String _shortMonthLabel(DateTime? date) {
    if (date == null) return '-';
    return _getMonthName(date.month);
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  String _formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  double _adaptiveChartInterval(double maxY) {
    if (maxY <= 0) return 1.0;

    // Target around 5 labels on Y axis to prevent overlapping text.
    final rawInterval = maxY / 5;
    final magnitude = math.pow(10, (math.log(rawInterval) / math.ln10).floor());
    final normalized = rawInterval / magnitude;

    double niceNormalized;
    if (normalized <= 1) {
      niceNormalized = 1;
    } else if (normalized <= 2) {
      niceNormalized = 2;
    } else if (normalized <= 5) {
      niceNormalized = 5;
    } else {
      niceNormalized = 10;
    }

    return niceNormalized * magnitude;
  }

  int _adaptiveLabelStep(int itemCount) {
    if (itemCount <= 6) return 1;
    if (itemCount <= 12) return 2;
    if (itemCount <= 24) return 3;
    return 4;
  }

  String _formatChartYAxis(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  int _estimatedReachFromStats(Map<String, dynamic> stats) {
    final explicitReach = _asInt(stats['estimated_reach']);
    if (explicitReach > 0) return explicitReach;

    final likes = _asInt(stats['total_likes']);
    final comments = _asInt(stats['total_comments']);
    return (likes + comments) * 20;
  }
}
