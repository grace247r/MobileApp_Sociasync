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
    const icons = <IconData>[
      Icons.home,
      Icons.access_time,
      Icons.message_outlined,
      Icons.person_outline,
    ];

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = index == selectedIndex;

          return IconButton(
            onPressed: () => onTap?.call(index),
            icon: Icon(
              icons[index],
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: isSelected ? 32 : 30,
            ),
            splashRadius: 24,
            tooltip: 'Menu ${index + 1}',
          );
        }),
      ),
    );
  }
}
