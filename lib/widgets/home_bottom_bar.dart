import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class HomeBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTabChanged;

  const HomeBottomBar({super.key, this.selectedIndex = 0, this.onTabChanged});

  Widget _icon({
    required BuildContext context,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scale = (MediaQuery.of(context).size.width / 390).clamp(0.9, 1.25);
    final containerSize = 60 * scale;
    final iconSize = 34 * scale;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Center(
          child: Icon(icon, color: AppColors.primary, size: iconSize),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barScale = (MediaQuery.of(context).size.width / 390).clamp(0.95, 1.2);
    return SizedBox(
      height: 66 * barScale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _icon(
            context: context,
            icon: Icons.home,
            selected: selectedIndex == 0,
            onTap: () => onTabChanged?.call(0),
          ),
          _icon(
            context: context,
            icon: Icons.menu_book,
            selected: selectedIndex == 1,
            onTap: () => onTabChanged?.call(1),
          ),
          _icon(
            context: context,
            icon: Icons.volunteer_activism,
            selected: selectedIndex == 2,
            onTap: () => onTabChanged?.call(2),
          ),
          _icon(
            context: context,
            icon: Icons.person,
            selected: selectedIndex == 3,
            onTap: () => onTabChanged?.call(3),
          ),
        ],
      ),
    );
  }
}
