import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/photo_picker_button.dart';
import '../theme/app_theme.dart';
import 'recipe_result_screen.dart';

class AllergyScreen extends StatelessWidget {
  final ValueChanged<NavTab> onTabSelected;
  final NavTab currentTab;

  const AllergyScreen({
    super.key,
    required this.onTabSelected,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return _CameraBaseScreen(
      title: '알레르기 검사',
      currentTab: currentTab,
      onTabSelected: onTabSelected,
      onPhotoTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipeResultScreen()),
      ),
    );
  }
}

class RecipeScreen extends StatelessWidget {
  final ValueChanged<NavTab> onTabSelected;
  final NavTab currentTab;

  const RecipeScreen({
    super.key,
    required this.onTabSelected,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return _CameraBaseScreen(
      title: '음식 레시피',
      currentTab: currentTab,
      onTabSelected: onTabSelected,
      onPhotoTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipeResultScreen()),
      ),
    );
  }
}

class LeftoverScreen extends StatelessWidget {
  final ValueChanged<NavTab> onTabSelected;
  final NavTab currentTab;

  const LeftoverScreen({
    super.key,
    required this.onTabSelected,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return _CameraBaseScreen(
      title: '남은 음식 레시피',
      currentTab: currentTab,
      onTabSelected: onTabSelected,
      onPhotoTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipeResultScreen()),
      ),
    );
  }
}

class _CameraBaseScreen extends StatelessWidget {
  final String title;
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabSelected;
  final VoidCallback? onPhotoTap;

  const _CameraBaseScreen({
    required this.title,
    required this.currentTab,
    required this.onTabSelected,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.grid_view_rounded, size: 28),
                  color: AppColors.textPrimary,
                  onPressed: () {},
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PhotoPickerButton(onTap: onPhotoTap),
                ],
              ),
            ),
            BottomNavBar(
              currentTab: currentTab,
              onTabSelected: onTabSelected,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
