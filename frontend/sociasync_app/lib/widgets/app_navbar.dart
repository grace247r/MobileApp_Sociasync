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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final navBarHeight = (screenWidth * 0.16).clamp(60.0, 74.0).toDouble();
    final iconSize = (screenWidth * 0.062).clamp(22.0, 26.0).toDouble();

    const iconAssets = <String>[
      'assets/home.png',
      'assets/calendar.png',
      'assets/Chat.png',
      'assets/Profile.png',
    ];
    const calendarActiveAsset = 'assets/calendar_active.png';
    const fallbackIcons = <IconData>[
      Icons.home_rounded,
      Icons.calendar_month_rounded,
      Icons.chat_bubble_rounded,
      Icons.person_rounded,
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(15, 10, 15, 18),
      child: Container(
        height: navBarHeight,
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
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
                child: Image.asset(
                  iconPath,
                  width: isSelected ? iconSize + 2 : iconSize,
                  height: isSelected ? iconSize + 2 : iconSize,
                  color: Colors.white.withValues(
                    alpha: isSelected ? 1.0 : 0.52,
                  ),
                  colorBlendMode: BlendMode.modulate,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      fallbackIcons[index],
                      size: isSelected ? iconSize + 2 : iconSize,
                      color: Colors.white.withValues(
                        alpha: isSelected ? 1.0 : 0.52,
                      ),
                    );
                  },
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
