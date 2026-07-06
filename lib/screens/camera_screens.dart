import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/allergen_map.dart';
import '../services/allergy_api.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/photo_picker_button.dart';
import '../theme/app_theme.dart';
import 'recipe_result_screen.dart';

class AllergyScreen extends StatefulWidget {
  final ValueChanged<NavTab> onTabSelected;
  final NavTab currentTab;

  const AllergyScreen({
    super.key,
    required this.onTabSelected,
    required this.currentTab,
  });

  @override
  State<AllergyScreen> createState() => _AllergyScreenState();
}

class _AllergyScreenState extends State<AllergyScreen> {
  bool _loading = false;

  Future<void> _handleGalleryTap() async {
    if (_loading) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      final result = await AllergyApi.detect(File(picked.path));
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllergyResultScreen(
            imagePath: picked.path,
            allergenNames: result.allergens,
            cached: result.cached,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검사 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handlePhotoTap() async {
    if (_loading) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera, // ImageSource.gallery
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      final result = await AllergyApi.detect(File(picked.path));
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllergyResultScreen(
            imagePath: picked.path,
            allergenNames: result.allergens,
            cached: result.cached,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검사 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CameraBaseScreen(
          title: '알레르기 검사',
          subtitle: '제품 성분표를 촬영해 주세요',
          currentTab: widget.currentTab,
          onTabSelected: widget.onTabSelected,
          onPhotoTap: _handlePhotoTap,
          onGalleryTap: _handleGalleryTap,
        ),
        if (_loading)
          ColoredBox(
            color: Colors.black.withOpacity(0.45),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class AllergyResultScreen extends StatelessWidget {
  final String imagePath;
  final List<String> allergenNames;
  final bool cached;

  const AllergyResultScreen({
    super.key,
    required this.imagePath,
    required this.allergenNames,
    required this.cached,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('알레르기 검사 결과')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 28),
              Text('검출된 알레르기 성분', style: textTheme.titleLarge),
              const SizedBox(height: 16),
              if (allergenNames.isEmpty)
                const _ResultBanner(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.primary,
                  background: AppColors.primaryLight,
                  message: '검출된 알레르기 성분이 없습니다',
                )
              else
                ...allergenNames.map(
                  (name) => _AllergenTile(name: name),
                ),
              if (cached) ...[
                const SizedBox(height: 8),
                Text(
                  '※ 캐시된 응답',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String message;

  const _ResultBanner({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergenTile extends StatelessWidget {
  final String name;

  const _AllergenTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
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
      subtitle: '음식 사진을 촬영해 주세요',
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
      subtitle: '남은 재료를 촬영해 주세요',
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
  final String? subtitle;
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabSelected;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onGalleryTap;

  const _CameraBaseScreen({
    required this.title,
    required this.currentTab,
    required this.onTabSelected,
    this.subtitle,
    this.onPhotoTap,
  });

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // const SizedBox(height: 8),
            // ListTile(
            //   leading: const Icon(Icons.science_outlined, color: AppColors.primary),
            //   title: const Text('알레르기 검사'),
            //   onTap: () {
            //     Navigator.pop(ctx);
            //     onTabSelected(NavTab.allergy); // 실제 enum 값에 맞게 수정
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.restaurant_menu, color: AppColors.primary),
            //   title: const Text('음식 레시피'),
            //   onTap: () {
            //     Navigator.pop(ctx);
            //     onTabSelected(NavTab.recipe);
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.rice_bowl_outlined, color: AppColors.primary),
            //   title: const Text('남은 음식 레시피'),
            //   onTap: () {
            //     Navigator.pop(ctx);
            //     onTabSelected(NavTab.leftover);
            //   },
            // ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.grid_view_rounded, size: 28),
                  onPressed: () => _openMenu(context),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 36),
                  PhotoPickerButton(onTap: onPhotoTap, onGalleryTap: onGalleryTap),
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
