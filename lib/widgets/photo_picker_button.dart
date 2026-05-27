import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhotoPickerButton extends StatelessWidget {
  final VoidCallback? onTap;

  const PhotoPickerButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          color: AppColors.photoButton,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 100,
              color: Color(0xFFBBBBBB),
            ),
            const SizedBox(height: 16),
            Text(
              '클릭해서 사진 찍기',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textOnPhoto.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
