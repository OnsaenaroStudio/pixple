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
          subtitle: '제품 성분표또는 음식을 촬영해 주세요',
          currentTab: widget.currentTab,
          onTabSelected: widget.onTabSelected,
          onPhotoTap: _handlePhotoTap,
          onGalleryTap: _handleGalleryTap,
        ),
        if (_loading)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.45),
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
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
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
    this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      endDrawer: _AppDrawer(onTabSelected: onTabSelected),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.grid_view_rounded, size: 28),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
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

class _AppDrawer extends StatelessWidget {
  final ValueChanged<NavTab> onTabSelected;

  const _AppDrawer({required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.eco, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pixple',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                '메뉴',
                style: textTheme.labelMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            _DrawerItem(
              icon: Icons.science_outlined,
              label: '알레르기 검사',
              onTap: () {
                Navigator.pop(context);
                onTabSelected(NavTab.allergy); // 실제 enum 값에 맞게 수정
              },
            ),
            _DrawerItem(
              icon: Icons.forum_outlined,
              label: '커뮤니티',
              onTap: () {
                Navigator.pop(context);
                onTabSelected(NavTab.community);
              },
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: '설정',
              onTap: () {
                Navigator.pop(context);
                // TODO: 설정 화면으로 이동
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.info_outline,
              label: '앱 정보',
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Pixple',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.eco,
                      color: AppColors.primary, size: 40),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'v1.0.0',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}
