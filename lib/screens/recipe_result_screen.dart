import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecipeResultScreen extends StatelessWidget {
  final List<RecipeStep> steps;

  const RecipeResultScreen({
    super.key,
    this.steps = const [
      RecipeStep(title: '레시피 스탭 1', description: '재료를 준비합니다. 필요한 재료를 손질하고 계량합니다.'),
      RecipeStep(title: '레시피 스탭 2', description: '팬을 중불로 가열하고 기름을 두릅니다.'),
      RecipeStep(title: '레시피 스탭 3', description: '재료를 넣고 5분간 볶아줍니다. 간을 맞춥니다.'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                '레시피',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _BackButton(onTap: () => Navigator.pop(context)),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _RecipeStepCard(
                  step: steps[index],
                  stepNumber: index + 1,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 4),
            Text(
              '뒤로가기',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeStepCard extends StatelessWidget {
  final RecipeStep step;
  final int stepNumber;

  const _RecipeStepCard({required this.step, required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeStep {
  final String title;
  final String description;

  const RecipeStep({required this.title, required this.description});
}
