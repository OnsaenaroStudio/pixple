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

      final names = result.allergens.map(allergenName).toList(growable: false);

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
    return Scaffold(
      appBar: AppBar( title: const Text('알레르기 검사 결과'),),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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

              const SizedBox(height: 24),

              const Text(
                '알레르기 검사 성분',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              if (allergenNames.isEmpty) {
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Text(
                    '검출된 알레르기 성분이 없습니다 ✅',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              } else {
                Column(
                  children: allergenNames.map((name) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.red.withOpacity(0.08),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(name,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600,),),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              },

              if (cached)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '※ 캐시된 응답',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
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
