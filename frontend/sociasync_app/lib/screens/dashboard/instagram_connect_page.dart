import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'package:sociasync_app/services/instagram_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';

class InstagramConnectPage extends StatefulWidget {
  const InstagramConnectPage({super.key});

  @override
  State<InstagramConnectPage> createState() => _InstagramConnectPageState();
}

class _InstagramConnectPageState extends State<InstagramConnectPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  bool _isScraping = false;
  String _userName = 'User';
  String? _connectedUsername;
  String? _lastMessage;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await Future.wait([_loadUserName(), _loadDashboardState()]);
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
      // Keep fallback username when profile endpoint fails.
    }
  }

  Future<void> _loadDashboardState() async {
    try {
      final data = await InstagramService.getDashboard();
      if (!mounted) return;

      final connected = data['instagram_connected'] == true;
      final username = (data['instagram_username'] ?? '').toString();

      setState(() {
        _connectedUsername = connected && username.isNotEmpty ? username : null;
        if (_connectedUsername != null &&
            _usernameController.text.trim().isEmpty) {
          _usernameController.text = '@${_connectedUsername!}';
        }
      });
    } catch (_) {
      // Keep page interactive even when dashboard endpoint is unavailable.
    }
  }

  Future<void> _connectUsername() async {
    final raw = _usernameController.text.trim();
    if (raw.isEmpty) {
      _showSnack('Username Instagram tidak boleh kosong.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await InstagramService.connectUsername(raw);
      if (!mounted) return;

      final username = (result['instagram_username'] ?? '').toString();
      setState(() {
        _connectedUsername = username.isNotEmpty
            ? username
            : raw.replaceFirst('@', '');
        _lastMessage = (result['message'] ?? 'Instagram berhasil dihubungkan.')
            .toString();
      });

      _showSnack(_lastMessage!);
    } on InstagramServiceException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        'Terjadi kesalahan saat menghubungkan Instagram.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _triggerScrape() async {
    if (_connectedUsername == null || _connectedUsername!.isEmpty) {
      _showSnack('Hubungkan username Instagram dulu.', isError: true);
      return;
    }

    setState(() => _isScraping = true);
    try {
      final result = await InstagramService.triggerScrape(resultsLimit: 60);
      if (!mounted) return;

      final posts = (result['posts_scraped'] ?? 0).toString();
      _showSnack('Scrape selesai. Total post diproses: $posts.');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on InstagramServiceException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Gagal memulai scraping.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isScraping = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : primaryBlue,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(userName: _userName, primaryColor: primaryBlue),
                const SizedBox(height: 24),
                const Text(
                  'Connect Instagram',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D5093),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hubungkan username Instagram kamu untuk menampilkan Dashboard dan Analytics real-time.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4D5E7C),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7CD9).withOpacity(0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instagram Username',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D5093),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: '@username',
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _connectUsername,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Connect Username',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_connectedUsername != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Terhubung ke @$_connectedUsername',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D5093),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isScraping ? null : _triggerScrape,
                            icon: _isScraping
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.bolt_rounded),
                            label: Text(
                              _isScraping ? 'Scraping...' : 'Trigger Scrape',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryBlue,
                              side: BorderSide(color: primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                if (_lastMessage != null)
                  Text(
                    _lastMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4D5E7C),
                    ),
                  ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                      );
                    },
                    child: const Text('Kembali ke Dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
