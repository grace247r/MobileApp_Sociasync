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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
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
          _buildNavItem('assets/Home (1).png', 0),
          // Pastikan nama file "Calender.png" sesuai folder kamu
          _buildNavItem('assets/Calender.png', 1),
          _buildNavItem('assets/Chat.png', 2),
          _buildNavItem('assets/profile.png', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String assetPath, int index) {
    final bool isActive = selectedIndex == index;

    // LOGIKA SWITCH: Pastikan string ini sama persis dengan nama file di folder assets
    String finalAsset = assetPath;
    if (index == 1 && isActive) {
      finalAsset = 'assets/Calender (setelah diklik).png';
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            finalAsset,
            // Kasih width/height sedikit lebih besar kalau aktif biar "pop out"
            width: isActive ? 30 : 28,
            height: isActive ? 30 : 28,
            // Putih solid kalau aktif, agak redup kalau nggak
            color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
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
