import 'package:flutter/material.dart';

import '../data/allergy_data.dart';
import '../models/allergy_info.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

// todo: fix Exception caught by Flutter framework
class AllergyInfoScreen extends StatelessWidget {

  final ValueChanged<NavTab> onTabSelected;
  final NavTab currentTab;

  const AllergyInfoScreen({
    super.key,
    required this.onTabSelected,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("알레르기 정보"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: allergyList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                return _AllergyCard(
                  info: allergyList[index],
                );
              },
            ),
          ),
          BottomNavBar(
            currentTab: currentTab,
            onTabSelected: onTabSelected,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AllergyCard extends StatelessWidget {
  final AllergyInfo info;

  const _AllergyCard({
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ExpansionTile(
        leading: Text(
          info.emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          info.title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(info.description),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          _Section(
            title: "대표 증상",
            items: info.symptoms,
          ),
          const SizedBox(height: 16),
          _Section(
            title: "주의 음식",
            items: info.avoidFoods,
          ),
          const SizedBox(height: 16),
          _Section(
            title: "대체 가능 음식",
            items: info.alternatives,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;

  const _Section({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: text.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (e) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(e),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}