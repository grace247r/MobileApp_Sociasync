import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final Color? backgroundColor;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.backgroundColor,
  });

  final Color primaryBlue = const Color(0xFF1D5093);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallDevice = screenHeight < 600;

    // Responsive sizing
    final navbarHeight = isSmallDevice ? 56.0 : 70.0;
    final iconBaseSize = isSmallDevice ? 20.0 : 28.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: navbarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? primaryBlue,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? primaryBlue).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, -1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('assets/home.png', 0, iconBaseSize),
          _buildNavItem('assets/calendar.png', 1, iconBaseSize),
          _buildNavItem('assets/Chat.png', 2, iconBaseSize),
          _buildNavItem('assets/Profile.png', 3, iconBaseSize),
        ],
      ),
    );
  }

  Widget _buildNavItem(String assetPath, int index, double baseIconSize) {
    final bool isActive = selectedIndex == index;

    // LOGIKA SWITCH: Calendar menggunakan asset berbeda saat aktif
    String finalAsset = assetPath;
    if (index == 1 && isActive) {
      finalAsset = 'assets/calendar_active.png';
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            finalAsset,
            // Responsive sizing: lebih besar kalau aktif
            width: isActive ? baseIconSize + 2 : baseIconSize,
            height: isActive ? baseIconSize + 2 : baseIconSize,
            fit: BoxFit.contain,
            // Kontras putih lebih kuat saat aktif
            color: Colors.white.withOpacity(isActive ? 1.0 : 0.52),
            colorBlendMode: BlendMode.modulate,
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
