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

  Future<void> _handlePhotoTap() async {
    if (_loading) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera, // 또는 ImageSource.gallery
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      final result = await AllergyApi.detect(File(picked.path));
      if (!mounted) return;

      final names =
      result.allergens.map(allergenName).toList(growable: false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllergyResultScreen(
            imagePath: picked.path,
            allergenCodes: result.allergens,
            allergenNames: names,
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
          currentTab: widget.currentTab,
          onTabSelected: widget.onTabSelected,
          onPhotoTap: _handlePhotoTap,
        ),
        if (_loading)
          const ColoredBox(
            color: Color(0x80000000),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class AllergyResultScreen extends StatelessWidget {
  final String imagePath;
  final List<int> allergenCodes;
  final List<String> allergenNames;
  final bool cached;

  const AllergyResultScreen({
    super.key,
    required this.imagePath,
    required this.allergenCodes,
    required this.allergenNames,
    required this.cached,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알레르기 검사 결과')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imagePath), height: 220, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text(
                allergenNames.isEmpty
                    ? '검출된 항원이 없습니다 ✅'
                    : '검출된 항원 (${allergenNames.length}건)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: allergenNames.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    leading: CircleAvatar(child: Text('${allergenCodes[i]}')),
                    title: Text(allergenNames[i]),
                  ),
                ),
              ),
              if (cached)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('※ 캐시된 응답', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        ),
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
