import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixple/screens/allergen_info_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/camera_screens.dart';
import 'screens/community_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: PixpleApp()));
}

class PixpleApp extends StatelessWidget {
  const PixpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixple',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

final _currentTabProvider = StateProvider<NavTab>((ref) => NavTab.allergy);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(_currentTabProvider);

    void onTabSelected(NavTab tab) {
      ref.read(_currentTabProvider.notifier).state = tab;
    }

    return switch (currentTab) {
      NavTab.allergy => AllergyScreen(
          currentTab: currentTab,
          onTabSelected: onTabSelected,
        ),
      NavTab.recipe => RecipeScreen(
          currentTab: currentTab,
          onTabSelected: onTabSelected,
        ),
      NavTab.leftover => LeftoverScreen(
          currentTab: currentTab,
          onTabSelected: onTabSelected,
        ),
      NavTab.community => CommunityScreen(
          currentTab: currentTab,
          onTabSelected: onTabSelected,
        ),
      NavTab.allergy_info => AllergyInfoScreen(
        currentTab: currentTab,
        onTabSelected: onTabSelected,
      )
    };
  }
}
