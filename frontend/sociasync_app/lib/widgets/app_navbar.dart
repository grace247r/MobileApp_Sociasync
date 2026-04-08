import 'package:flutter/material.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({
    super.key,
    required this.selectedIndex,
    this.onTap,
    this.backgroundColor = const Color(0xFF1D5093),
  });

  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final iconAssets = <String>[
      'assets/home.png',
      'assets/calendar.png',
      'assets/Chat.png',
      'assets/Profile.png',
    ];
    const calendarActiveAsset = 'assets/calendar_active.png';

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallDevice = screenHeight < 600;

    // Responsive sizing
    final navbarHeight = isSmallDevice ? 56.0 : 68.0;
    final iconBaseSize = isSmallDevice ? 20.0 : 24.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 18),
      height: navbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(iconAssets.length, (index) {
          final isSelected = index == selectedIndex;
          final iconPath = (index == 1 && isSelected)
              ? calendarActiveAsset
              : iconAssets[index];

          return IconButton(
            onPressed: () => onTap?.call(index),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 44,
              minHeight: navbarHeight * 0.7,
            ),
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.12)
                    : Colors.transparent,
              ),
              child: Image.asset(
                iconPath,
                width: isSelected ? iconBaseSize + 3 : iconBaseSize,
                height: isSelected ? iconBaseSize + 3 : iconBaseSize,
                fit: BoxFit.contain,
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.52),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            splashRadius: 22,
            tooltip: 'Menu ${index + 1}',
          );
        }),
      ),
    );
  }
}
