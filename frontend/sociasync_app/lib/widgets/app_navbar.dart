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

  static const double _navBarHeight = 68;

  @override
  Widget build(BuildContext context) {
    const iconAssets = <String>[
      'assets/home.png',
      'assets/calendar.png',
      'assets/chat.png',
      'assets/profile.png',
    ];
    const calendarActiveAsset = 'assets/calendar_active.png';

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(15, 10, 15, 18),
      child: Container(
        height: _navBarHeight,
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
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
                  width: isSelected ? 27 : 24,
                  height: isSelected ? 27 : 24,
                  color: Colors.white.withOpacity(isSelected ? 1.0 : 0.52),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
              splashRadius: 22,
              tooltip: 'Menu ${index + 1}',
            );
          }),
        ),
      ),
    );
  }
}
