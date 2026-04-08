import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/auth/login_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _resolveNextPage();
      }
    });
  }

  Future<void> _resolveNextPage() async {
    final hasSession = await AuthService.hasSession();
    if (!mounted) return;

    final destination = hasSession ? const DashboardPage() : const LoginPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final barWidth = screenWidth * 0.45;
    const barHeight = 14.0;
    const barRadius = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo di tengah layar
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),

          // Loading bar di bawah tengah
          Positioned(
            bottom: screenHeight * 0.18,
            left: (screenWidth - barWidth) / 2,
            child: SizedBox(
              width: barWidth,
              height: barHeight,
              child: Stack(
                children: [
                  // Track (background bar)
                  Container(
                    width: barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(barRadius),
                      border: Border.all(
                        color: const Color(0xFF1A3EC8),
                        width: 1.5,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  // Filled progress
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      return Container(
                        width: barWidth * _progressAnimation.value,
                        height: barHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(barRadius),
                          color: const Color(0xFF1A3EC8),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
