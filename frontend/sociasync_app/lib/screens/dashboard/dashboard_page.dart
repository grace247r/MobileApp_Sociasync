import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:sociasync_app/screens/analytics/monthly_summary_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/content_generator/content_generator_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'package:sociasync_app/services/instagram_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/instagram_manage_account_dialog.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';

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

  bool _isLoading = true;
  String? _errorMessage;
  bool _instagramConnected = false;
  String _instagramUsername = '';

  Map<String, dynamic>? _latestStats;
  List<Map<String, dynamic>> _statsHistory = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _bestPosts = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _loadUserName(),
      _loadUnreadCount(),
      _loadInstagramData(showLoader: true),
    ]);
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

  Future<void> _loadInstagramData({bool showLoader = false}) async {
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
      List<Map<String, dynamic>> bestPosts = const <Map<String, dynamic>>[];

      if (connected) {
        history = await InstagramService.getStatsHistory(limit: 7);
        try {
          final bestPostsResponse = await InstagramService.getBestPosts(
            limit: 6,
          );
          final postsRaw = bestPostsResponse['posts'];
          if (postsRaw is List) {
            bestPosts = postsRaw
                .whereType<Map>()
                .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
                .toList();
          }
        } catch (_) {
          bestPosts = const <Map<String, dynamic>>[];
        }
      }

      if (!mounted) return;
      setState(() {
        _instagramConnected = connected;
        _instagramUsername = username;
        _latestStats = latestStats;
        _statsHistory = history.reversed.toList();
        _bestPosts = bestPosts;
        _errorMessage = null;
      });
    } on InstagramServiceException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal memuat data Instagram.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _runScrapeAndRefresh() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Memulai scraping Instagram...'),
          backgroundColor: primaryBlue,
        ),
      );
      await InstagramService.triggerScrape(resultsLimit: 60);
      await _loadInstagramData(showLoader: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data Instagram berhasil diperbarui.'),
          backgroundColor: primaryBlue,
        ),
      );
    } on InstagramServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menjalankan scraping.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _openInstagramManageDialog() async {
    final updated = await showInstagramManageAccountDialog(
      context: context,
      initialUsername: _instagramUsername,
      primaryColor: primaryBlue,
    );
    if (!updated || !mounted) return;

    await _loadInstagramData(showLoader: true);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Username Instagram berhasil disimpan.'),
        backgroundColor: primaryBlue,
      ),
    );
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

                  _buildMainContent(),
                  const SizedBox(height: 25),

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

                  _buildSectionHeader('Best Performing Post', null),
                  const SizedBox(height: 15),
                  _buildBestPostsSection(),
                  const SizedBox(height: 40),

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
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: _currentIndex,
          backgroundColor: primaryBlue,
          onTap: _onNavbarTap,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
      );
    }

    if (_errorMessage != null) {
      return _buildInfoCard(
        title: 'Data belum bisa dimuat',
        subtitle: _errorMessage!,
        actionLabel: 'Coba Lagi',
        onTap: () => _loadInstagramData(showLoader: true),
      );
    }

    if (!_instagramConnected) {
      return _buildInfoCard(
        title: 'Instagram belum terhubung',
        subtitle:
            'Tambahkan username dulu supaya dashboard dan analytics menampilkan data real-time.',
        actionLabel: 'Connect Username',
        onTap: _openInstagramManageDialog,
      );
    }

    return _buildStatsCard();
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7CD9).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4C5D7A)),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _latestStats ?? <String, dynamic>{};
    final engagement = _asDouble(stats['engagement_percentage']);
    final followers = _asInt(stats['followers_count']);
    final totalPosts = _asInt(stats['total_posts']);
    final latestLikes = _asInt(stats['total_likes']);
    final latestComments = _asInt(stats['total_comments']);
    final estimatedReach = _asInt(stats['estimated_reach']) > 0
        ? _asInt(stats['estimated_reach'])
        : (latestLikes + latestComments) * 20;
    final metricItems = <MapEntry<String, String>>[
      MapEntry('${engagement.toStringAsFixed(2)}%', 'Engagement'),
      MapEntry(_formatCompact(estimatedReach), 'Reach'),
      MapEntry(_formatCompact(followers), 'Followers'),
      MapEntry(_formatCompact(totalPosts), 'Post'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7CD9).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Instagram @${_instagramUsername.isEmpty ? '-' : _instagramUsername}',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: _runScrapeAndRefresh,
                tooltip: 'Refresh from Scrape',
                icon: Icon(Icons.refresh_rounded, color: primaryBlue),
              ),
              IconButton(
                onPressed: _openInstagramManageDialog,
                tooltip: 'Manage Instagram',
                icon: Icon(Icons.settings_rounded, color: primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              final crossAxisCount = cardWidth >= 620 ? 4 : 2;
              final ratio = cardWidth >= 620
                  ? 1.75
                  : (cardWidth < 340 ? 1.45 : 1.65);

              return GridView.builder(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: ratio,
                ),
                itemCount: metricItems.length,
                itemBuilder: (context, index) {
                  final item = metricItems[index];
                  return _buildStatCard(item.key, item.value);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmoothChartCard() {
    if (!_instagramConnected) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Weekly chart akan tampil setelah Instagram terhubung dan data scrape tersedia.',
          style: TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    if (_statsHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Belum ada history statistik. Tekan refresh untuk menjalankan scrape.',
          style: TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    final chartSpots = <FlSpot>[];
    final labels = <String>[];
    var maxY = 10.0;

    for (var i = 0; i < _statsHistory.length; i++) {
      final item = _statsHistory[i];
      final y = _asDouble(item['engagement_percentage']);
      chartSpots.add(FlSpot(i.toDouble(), y));
      if (y > maxY) {
        maxY = y;
      }

      final date = DateTime.tryParse((item['recorded_at'] ?? '').toString());
      labels.add(_shortDayLabel(date));
    }

    final extraHeadroom = maxY >= 95 ? 8.0 : math.max(4.0, maxY * 0.08);
    final chartMaxY = math.max(5.0, maxY + extraHeadroom);
    final yInterval = chartMaxY <= 20 ? 5.0 : (chartMaxY <= 60 ? 10.0 : 20.0);

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
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipMargin: 10,
                tooltipBgColor: const Color(0xFF2B6FBF),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(0)}%',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
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
                        index >= labels.length) {
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
                  reservedSize: 40,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value > chartMaxY - 0.1) {
                      return const Text('');
                    }
                    final steps = (value / yInterval);
                    if ((steps - steps.roundToDouble()).abs() > 0.001) {
                      return const Text('');
                    }
                    return Text(
                      '${value.toInt()}%',
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
            maxX: (_statsHistory.length - 1).toDouble(),
            minY: 0,
            maxY: chartMaxY,
            lineBarsData: [
              LineChartBarData(
                spots: chartSpots,
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

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontSize: 26,
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

  Widget _buildBestPostsSection() {
    if (!_instagramConnected) {
      return const Text(
        'Best post akan tampil setelah akun terhubung.',
        style: TextStyle(color: Color(0xFF4D5E7C)),
      );
    }

    if (_bestPosts.isEmpty) {
      return const Text(
        'Belum ada data post. Jalankan scrape untuk mengambil data terbaru.',
        style: TextStyle(color: Color(0xFF4D5E7C)),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _bestPosts.length,
        itemBuilder: (context, index) {
          final post = _bestPosts[index];
          final likes = _asInt(post['likes']);
          final comments = _asInt(post['comments_count']);
          final imageUrl = _bestPostCoverUrl(post);

          return Container(
            width: 155,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: imageUrl.isEmpty
                        ? Container(
                            color: const Color(0xFFD9E7F9),
                            child: const Icon(
                              Icons.image_rounded,
                              color: Color(0xFF1D5093),
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            headers: const {
                              'User-Agent':
                                  'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
                              'Referer': 'https://www.instagram.com/',
                            },
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: const Color(0xFFD9E7F9),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Like ${_formatCompact(likes)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Com ${_formatCompact(comments)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  String _shortDayLabel(DateTime? date) {
    if (date == null) return '-';
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[date.weekday - 1];
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

  String _bestPostCoverUrl(Map<String, dynamic> post) {
    final candidates = [
      post['image_url'],
      post['thumbnail_url'],
      post['display_url'],
      post['media_url'],
      post['video_url'],
    ];

    for (final value in candidates) {
      final parsed = (value ?? '').toString().trim();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return '';
  }
}
