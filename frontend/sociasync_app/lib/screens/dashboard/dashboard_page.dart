import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/analytics/monthly_summary_page.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/content_generator/content_generator_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'package:sociasync_app/services/instagram_service.dart';
import 'package:sociasync_app/services/local_notification_service.dart';
import 'package:sociasync_app/services/tiktok_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/instagram_manage_account_dialog.dart';
import 'package:sociasync_app/widgets/tiktok_manage_account_dialog.dart';

enum SocialPlatform { instagram, tiktok }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 0;
  final PageController _analyticsPageController = PageController();

  String _userName = 'User';
  int _unreadCount = 0;
  bool _isLoading = true;

  int _analyticsPageIndex = 0;
  SocialPlatform _bestPerformancePlatform = SocialPlatform.instagram;

  bool _instagramConnected = false;
  String _instagramUsername = '';
  String? _instagramErrorMessage;
  Map<String, dynamic>? _latestInstagramStats;
  List<Map<String, dynamic>> _instagramStatsHistory =
      const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _bestInstagramPosts =
      const <Map<String, dynamic>>[];

  bool _tiktokConnected = false;
  String _tiktokUsername = '';
  String? _tiktokErrorMessage;
  Map<String, dynamic>? _latestTikTokStats;
  List<Map<String, dynamic>> _tiktokStatsHistory =
      const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _bestTikTokVideos = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analyticsPageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _showBackendNotificationsAsPopups();
    }
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);

    await _loadUserAndConnections();
    await Future.wait([
      _loadUnreadCount(),
      _loadInstagramData(),
      _loadTikTokData(),
    ]);

    await _showBackendNotificationsAsPopups();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserAndConnections() async {
    try {
      final profile = await AuthService.getMe();
      if (!mounted) return;

      final name = (profile['name'] ?? '').toString().trim();
      setState(() {
        if (name.isNotEmpty) _userName = name;

        _instagramConnected = profile['instagram_connected'] == true;
        _instagramUsername = (profile['instagram_username'] ?? '')
            .toString()
            .trim();

        _tiktokConnected = profile['tiktok_connected'] == true;
        _tiktokUsername = (profile['tiktok_username'] ?? '').toString().trim();
      });
    } catch (_) {
      // Keep fallback values.
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await AuthService.getUnreadNotificationCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Keep default value.
    }
  }

  Future<void> _showBackendNotificationsAsPopups() async {
    try {
      final notifications = await AuthService.getNotifications();
      final unreadNotifications = notifications.where((item) {
        return item['is_read'] != true;
      }).toList();

      if (unreadNotifications.isEmpty) {
        return;
      }

      for (final item in unreadNotifications) {
        final title = (item['title'] ?? 'Notification').toString().trim();
        final message = (item['message'] ?? '').toString().trim();
        await LocalNotificationService.showBackendNotification(
          title: title.isEmpty ? 'Notification' : title,
          body: message.isEmpty ? '-' : message,
          payload: 'notification:${item['id'] ?? ''}',
        );
      }

      await AuthService.markAllNotificationsRead();
      if (!mounted) return;
      setState(() => _unreadCount = 0);
    } catch (_) {
      // Keep dashboard usable even if popup sync fails.
    }
  }

  Future<void> _loadInstagramData() async {
    if (!_instagramConnected) {
      if (!mounted) return;
      setState(() {
        _latestInstagramStats = null;
        _instagramStatsHistory = const <Map<String, dynamic>>[];
        _bestInstagramPosts = const <Map<String, dynamic>>[];
        _instagramErrorMessage = null;
      });
      return;
    }

    try {
      final dashboard = await InstagramService.getDashboard();
      final latestStats = dashboard['latest_stats'] is Map
          ? Map<String, dynamic>.from(dashboard['latest_stats'] as Map)
          : null;

      final history = await InstagramService.getStatsHistory(limit: 7);

      List<Map<String, dynamic>> bestPosts = const <Map<String, dynamic>>[];
      try {
        final bestPostsResponse = await InstagramService.getBestPosts(limit: 6);
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

      if (!mounted) return;
      setState(() {
        _latestInstagramStats = latestStats;
        _instagramStatsHistory = history.reversed.toList();
        _bestInstagramPosts = bestPosts;
        _instagramErrorMessage = null;
      });
    } on InstagramServiceException catch (e) {
      if (!mounted) return;
      setState(() => _instagramErrorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _instagramErrorMessage = 'Gagal memuat data Instagram.');
    }
  }

  Future<void> _loadTikTokData() async {
    if (!_tiktokConnected) {
      if (!mounted) return;
      setState(() {
        _latestTikTokStats = null;
        _tiktokStatsHistory = const <Map<String, dynamic>>[];
        _bestTikTokVideos = const <Map<String, dynamic>>[];
        _tiktokErrorMessage = null;
      });
      return;
    }

    try {
      final dashboard = await TikTokService.getDashboard();
      final latestStats = dashboard['latest_stats'] is Map
          ? Map<String, dynamic>.from(dashboard['latest_stats'] as Map)
          : (dashboard.containsKey('latest_stats') ? null : dashboard);
      final history = await TikTokService.getStatsHistory(limit: 7);
      final bestVideosResponse = await TikTokService.getBestVideos(limit: 6);

      List<Map<String, dynamic>> bestVideos = const <Map<String, dynamic>>[];
      final videosRaw = bestVideosResponse['videos'];
      if (videosRaw is List) {
        bestVideos = videosRaw
            .whereType<Map>()
            .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _latestTikTokStats = latestStats;
        _tiktokStatsHistory = history.reversed.toList();
        _bestTikTokVideos = bestVideos;
        _tiktokErrorMessage = null;
      });
    } on TikTokServiceException catch (e) {
      if (!mounted) return;
      setState(() => _tiktokErrorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _tiktokErrorMessage = 'Gagal memuat data TikTok.');
    }
  }

  Future<void> _runInstagramScrapeAndRefresh() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Memulai scraping Instagram...'),
          backgroundColor: primaryBlue,
        ),
      );
      await InstagramService.triggerScrape(resultsLimit: 60);
      await _loadInstagramData();
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
    }
  }

  Future<void> _runTikTokScrapeAndRefresh() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Memulai scraping TikTok...'),
          backgroundColor: primaryBlue,
        ),
      );
      await TikTokService.triggerScrape(resultsLimit: 200);
      await _loadTikTokData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data TikTok berhasil diperbarui.'),
          backgroundColor: primaryBlue,
        ),
      );
    } on TikTokServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
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

    await _loadUserAndConnections();
    await _loadInstagramData();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Username Instagram berhasil disimpan.'),
        backgroundColor: primaryBlue,
      ),
    );
  }

  Future<void> _openTikTokManageDialog() async {
    final updated = await showTikTokManageAccountDialog(
      context: context,
      initialUsername: _tiktokUsername,
      primaryColor: primaryBlue,
    );
    if (!updated || !mounted) return;

    await _loadUserAndConnections();
    await _loadTikTokData();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Username TikTok berhasil disimpan.'),
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

                  _buildAnalyticsSwipeContent(),
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

                  _buildBestPerformanceHeader(),
                  const SizedBox(height: 15),
                  _buildBestPerformanceSection(),
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

  Widget _buildAnalyticsSwipeContent() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: _analyticsCardHeight(context),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    final cardHeight = _analyticsCardHeight(context);

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView(
            controller: _analyticsPageController,
            onPageChanged: (index) {
              setState(() {
                _analyticsPageIndex = index;
                _bestPerformancePlatform = index == 0
                    ? SocialPlatform.instagram
                    : SocialPlatform.tiktok;
              });
            },
            children: [_buildInstagramStatsCard(), _buildTikTokStatsCard()],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageIndicator(_analyticsPageIndex == 0),
            const SizedBox(width: 6),
            _buildPageIndicator(_analyticsPageIndex == 1),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: active ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? primaryBlue : primaryBlue.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildInstagramStatsCard() {
    if (!_instagramConnected) {
      return _buildInfoCard(
        title: 'Instagram belum terhubung',
        subtitle: 'Hubungkan username Instagram untuk menampilkan analytics.',
        actionLabel: 'Connect Instagram',
        onTap: _openInstagramManageDialog,
      );
    }

    if (_instagramErrorMessage != null) {
      return _buildInfoCard(
        title: 'Data Instagram belum bisa dimuat',
        subtitle: _instagramErrorMessage!,
        actionLabel: 'Coba Lagi',
        onTap: _loadInstagramData,
      );
    }

    final stats = _latestInstagramStats;
    if (stats == null) {
      return _buildInfoCard(
        title: 'Instagram siap dipakai',
        subtitle: 'Jalankan scrape pertama untuk mengisi statistik Instagram.',
        actionLabel: 'Run Scrape',
        onTap: _runInstagramScrapeAndRefresh,
      );
    }

    final engagement = _asDouble(stats['engagement_percentage']);
    final followers = _asInt(stats['followers_count']);
    final totalPosts = _asInt(stats['total_posts']);
    final reach = _asInt(stats['estimated_reach']) > 0
        ? _asInt(stats['estimated_reach'])
        : (_asInt(stats['total_likes']) + _asInt(stats['total_comments'])) * 20;

    return _buildStatsCard(
      title:
          'Instagram @${_instagramUsername.isEmpty ? '-' : _instagramUsername}',
      metricItems: [
        MapEntry('${engagement.toStringAsFixed(2)}%', 'Engagement'),
        MapEntry(_formatCompact(reach), 'Reach'),
        MapEntry(_formatCompact(followers), 'Followers'),
        MapEntry(_formatCompact(totalPosts), 'Post'),
      ],
      onRefresh: _runInstagramScrapeAndRefresh,
      onManage: _openInstagramManageDialog,
    );
  }

  Widget _buildTikTokStatsCard() {
    if (!_tiktokConnected) {
      return _buildInfoCard(
        title: 'TikTok belum terhubung',
        subtitle: 'Hubungkan username TikTok untuk menampilkan analytics.',
        actionLabel: 'Connect TikTok',
        onTap: _openTikTokManageDialog,
      );
    }

    if (_tiktokErrorMessage != null) {
      return _buildInfoCard(
        title: 'Data TikTok belum bisa dimuat',
        subtitle: _tiktokErrorMessage!,
        actionLabel: 'Coba Lagi',
        onTap: _loadTikTokData,
      );
    }

    final stats = _latestTikTokStats;
    if (stats == null) {
      return _buildInfoCard(
        title: 'TikTok siap dipakai',
        subtitle: 'Jalankan scrape pertama untuk mengisi statistik TikTok.',
        actionLabel: 'Run Scrape',
        onTap: _runTikTokScrapeAndRefresh,
      );
    }

    final engagement = _asDouble(stats['engagement_percentage']);
    final followers = _asInt(stats['followers_count']);
    final totalVideos = _asInt(stats['total_videos']);
    final reach = _asInt(stats['total_views']);

    return _buildStatsCard(
      title: 'TikTok @${_tiktokUsername.isEmpty ? '-' : _tiktokUsername}',
      metricItems: [
        MapEntry('${engagement.toStringAsFixed(2)}%', 'Engagement'),
        MapEntry(_formatCompact(reach), 'Reach'),
        MapEntry(_formatCompact(followers), 'Followers'),
        MapEntry(_formatCompact(totalVideos), 'Video'),
      ],
      onRefresh: _runTikTokScrapeAndRefresh,
      onManage: _openTikTokManageDialog,
    );
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

  double _analyticsCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final extraForText = textScale > 1 ? (textScale - 1) * 18 : 0.0;

    final baseHeight = switch (width) {
      >= 900 => 360.0,
      >= 700 => 340.0,
      >= 430 => 320.0,
      >= 380 => 305.0,
      _ => 292.0,
    };

    // Small safety headroom avoids sub-pixel overflow on some devices.
    return baseHeight + extraForText + 2;
  }

  Widget _buildStatsCard({
    required String title,
    required List<MapEntry<String, String>> metricItems,
    required VoidCallback onRefresh,
    required VoidCallback onManage,
  }) {
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
                  title,
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                tooltip: 'Refresh from Scrape',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.refresh_rounded, color: primaryBlue),
              ),
              IconButton(
                onPressed: onManage,
                tooltip: 'Manage Username',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
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
    final platform = _analyticsPageIndex == 0
        ? SocialPlatform.instagram
        : SocialPlatform.tiktok;

    final connected = platform == SocialPlatform.instagram
        ? _instagramConnected
        : _tiktokConnected;
    final errorMessage = platform == SocialPlatform.instagram
        ? _instagramErrorMessage
        : _tiktokErrorMessage;
    final history = platform == SocialPlatform.instagram
        ? _instagramStatsHistory
        : _tiktokStatsHistory;

    if (!connected) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          platform == SocialPlatform.instagram
              ? 'Weekly chart Instagram akan tampil setelah akun terhubung.'
              : 'Weekly chart TikTok akan tampil setelah akun terhubung.',
          style: const TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          errorMessage,
          style: const TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7CD9).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          platform == SocialPlatform.instagram
              ? 'Belum ada history Instagram. Tekan refresh untuk scrape.'
              : 'Belum ada history TikTok. Tekan refresh untuk scrape.',
          style: const TextStyle(color: Color(0xFF4D5E7C)),
        ),
      );
    }

    final chartSpots = <FlSpot>[];
    final labels = <String>[];
    var maxY = 10.0;

    for (var i = 0; i < history.length; i++) {
      final item = history[i];
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
            maxX: (history.length - 1).toDouble(),
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

  Widget _buildBestPerformanceHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Best Performance',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7CD9).withOpacity(0.22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primaryBlue.withOpacity(0.16)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SocialPlatform>(
              value: _bestPerformancePlatform,
              itemHeight: 48,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: const Color(0xFF1D5093),
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
              items: const [
                DropdownMenuItem(
                  value: SocialPlatform.instagram,
                  child: Text(
                    'Instagram',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: SocialPlatform.tiktok,
                  child: Text(
                    'TikTok',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _bestPerformancePlatform = value);
              },
              selectedItemBuilder: (context) => const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Instagram',
                    style: TextStyle(
                      color: Color(0xFF123B74),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'TikTok',
                    style: TextStyle(
                      color: Color(0xFF123B74),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestPerformanceSection() {
    if (_bestPerformancePlatform == SocialPlatform.instagram) {
      return _buildBestInstagramPosts();
    }
    return _buildBestTikTokVideos();
  }

  Widget _buildBestInstagramPosts() {
    if (!_instagramConnected) {
      return const Text(
        'Hubungkan Instagram dulu untuk melihat best post.',
        style: TextStyle(color: Color(0xFF4D5E7C)),
      );
    }

    if (_bestInstagramPosts.isEmpty) {
      return const Text(
        'Belum ada data post Instagram. Jalankan scrape untuk mengambil data terbaru.',
        style: TextStyle(color: Color(0xFF4D5E7C)),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _bestInstagramPosts.length,
        itemBuilder: (context, index) {
          final post = _bestInstagramPosts[index];
          final likes = _asInt(post['likes']);
          final comments = _asInt(post['comments_count']);
          final imageUrl = _firstNotEmpty([
            post['image_url'],
            post['thumbnail_url'],
            post['display_url'],
            post['media_url'],
            post['video_url'],
          ]);

          return _buildMediaCard(
            imageUrl: imageUrl,
            leftMetric: 'Like ${_formatCompact(likes)}',
            rightMetric: 'Com ${_formatCompact(comments)}',
          );
        },
      ),
    );
  }

  Widget _buildBestTikTokVideos() {
    if (!_tiktokConnected) {
      return const Text(
        'Hubungkan TikTok dulu untuk melihat best video.',
        style: TextStyle(color: Color(0xFF4D5E7C)),
      );
    }

    if (_bestTikTokVideos.isEmpty) {
      return const Text(
        'Belum ada data video TikTok. Jalankan scrape untuk mengambil data terbaru.',
        style: TextStyle(color: Color(0xFF4D5E7C)),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _bestTikTokVideos.length,
        itemBuilder: (context, index) {
          final video = _bestTikTokVideos[index];
          final likes = _asInt(video['likes']);
          final views = _asInt(video['views']);
          final imageUrl = _firstNotEmpty([
            video['thumbnail_url'],
            video['image_url'],
          ]);

          return _buildMediaCard(
            imageUrl: imageUrl,
            leftMetric: 'Like ${_formatCompact(likes)}',
            rightMetric: 'View ${_formatCompact(views)}',
          );
        },
      ),
    );
  }

  Widget _buildMediaCard({
    required String imageUrl,
    required String leftMetric,
    required String rightMetric,
  }) {
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
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFD9E7F9),
                          child: const Icon(Icons.image_not_supported_outlined),
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
                  leftMetric,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  rightMetric,
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

  String _firstNotEmpty(List<dynamic> values) {
    for (final value in values) {
      final parsed = (value ?? '').toString().trim();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return '';
  }
}
