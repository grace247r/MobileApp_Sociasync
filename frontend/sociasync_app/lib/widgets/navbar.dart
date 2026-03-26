import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.selectedIndex, required this.onTap});

  final Color primaryBlue = const Color(0xFF1D5093);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 0), // Icon Rumah
          _buildNavItem(Icons.history, 1), // Icon History/Clock
          _buildNavItem(Icons.chat_bubble_outline, 2), // Icon Chat
          _buildNavItem(Icons.person_outline, 3), // Icon Profile
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        size: 28,
        // Jika aktif warna putih terang, jika tidak agak transparan
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
      ),
    );
  }
}
