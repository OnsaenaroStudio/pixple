import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NavTab { allergy, recipe, leftover, community, allergy_info }

class BottomNavBar extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabSelected;

  const BottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        borderRadius: BorderRadius.circular(33),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavButton(
            icon: Icons.eco,
            label: '알레르기',
            isActive: currentTab == NavTab.allergy,
            onTap: () => onTabSelected(NavTab.allergy),
          ),
          // _NavButton(
          //   icon: Icons.menu_book,
          //   label: '레시피',
          //   isActive: currentTab == NavTab.recipe,
          //   onTap: () => onTabSelected(NavTab.recipe),
          // ),
          // _NavButton(
          //   icon: Icons.delete_outline,
          //   label: '남은 음식',
          //   isActive: currentTab == NavTab.leftover,
          //   onTap: () => onTabSelected(NavTab.leftover),
          // ),
          _NavButton(
            icon: Icons.chat_bubble_outline,
            label: '커뮤',
            isActive: currentTab == NavTab.community,
            onTap: () => onTabSelected(NavTab.community),
          ),
          _NavButton(
            icon: Icons.info_outlined,
            label: '정보',
            isActive: currentTab == NavTab.allergy_info,
            onTap: () => onTabSelected(NavTab.allergy_info),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.navIconActive : AppColors.navIconInactive;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.primaryLight : Colors.transparent,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
