import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhotoPickerButton extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onGalleryTap;

  const PhotoPickerButton({super.key, this.onTap, this.onGalleryTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.divider, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '탭해서 사진 찍기',
                    style: textTheme.titleMedium
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onGalleryTap,
          icon: const Icon(Icons.photo_library_outlined, size: 18),
          label: const Text('갤러리에서 선택'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
