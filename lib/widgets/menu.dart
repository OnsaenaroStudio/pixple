import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/local_identity.dart';
import '../theme/app_theme.dart';
import 'bottom_nav_bar.dart';

class AppDrawer extends StatelessWidget {
  final ValueChanged<NavTab> onTabSelected;

  const AppDrawer({required this.onTabSelected});

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
            /*_DrawerItem(
              icon: Icons.settings_outlined,
              label: '설정',
              onTap: () {
                Navigator.pop(context);
                // TODO: 설정 화면으로 이동
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),*/
            _DrawerItem(
              icon: Icons.person,
              label: '사용자 정보',
              onTap: () async {
                Navigator.pop(context);

                final userId = await LocalIdentity.getOrCreateUserId();
                final userName = await LocalIdentity.getUserName();

                final controller = TextEditingController(text: userName);

                if (!context.mounted) return;

                await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text("사용자 정보"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText("사용자 ID\n$userId"),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: "사용자 이름",
                              border: OutlineInputBorder(),
                            ),
                            maxLength: 20,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("취소"),
                        ),
                        FilledButton(
                          onPressed: () async {
                            final name = controller.text.trim();

                            if (name.isEmpty) {
                              return;
                            }

                            await LocalIdentity.setUserName(name);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("사용자 이름이 변경되었습니다."),
                                ),
                              );
                            }
                          },
                          child: const Text("저장"),
                        ),
                      ],
                    );
                  },
                );
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
