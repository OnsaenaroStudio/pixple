import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../services/community_api.dart';
import '../models/community_models.dart';
import '../widgets/menu.dart';
import 'community_detail_screen.dart';
import 'write_screen.dart';

class CommunityScreen extends StatefulWidget {
  final ValueChanged<NavTab> onTabSelected;
  final NavTab currentTab;

  const CommunityScreen({
    super.key,
    required this.onTabSelected,
    required this.currentTab,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = true;
  String? _error;
  List<CommunityArticle> _articles = [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load(page: 1);
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await CommunityApi.fetchArticles(page: page);
      setState(() {
        _page = res.page;
        _articles = res.articles;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _goWrite() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WriteScreen()),
    );
    await _load(page: 1);
  }

  Future<void> _openDetail(CommunityArticle article) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(article: article),
      ),
    );
    await _load(page: deleted == true ? 1 : _page);
  }

  void _onDrawerTabSelected(NavTab tab) {
    widget.onTabSelected(tab);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      endDrawer: AppDrawer(
        onTabSelected: _onDrawerTabSelected,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Text(
                    '커뮤니티',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _WriteButton(onTap: _goWrite),
                  const SizedBox(width: 4),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.grid_view_rounded,
                        size: 28,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(page: _page),
                child: _buildBody(),
              ),
            ),
            BottomNavBar(
              currentTab: widget.currentTab,
              onTabSelected: widget.onTabSelected,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const _PostSkeletonCard(),
      );
    }

    if (_error != null) {
      return _MessageView(
        icon: Icons.wifi_off_rounded,
        message: '불러오기에 실패했어요.\n$_error',
        actionLabel: '다시 시도',
        onAction: () => _load(page: 1),
      );
    }

    if (_articles.isEmpty) {
      return const _MessageView(
        icon: Icons.forum_outlined,
        message: '아직 게시글이 없어요.\n첫 글을 작성해 보세요!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: _articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _PostCard(
        article: _articles[i],
        onTap: () => _openDetail(_articles[i]),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 44),
              ),
              child: Text(actionLabel!),
            ),
          ),
        ],
      ],
    );
  }
}

class _WriteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WriteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                '글 쓰기',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityArticle article;
  final VoidCallback onTap;
  const _PostCard({required this.article, required this.onTap});

  String _dateText(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.hashtags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: article.hashtags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$t',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  article.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  article.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _dateText(article.createdAt),
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostSkeletonCard extends StatelessWidget {
  const _PostSkeletonCard();

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(140, 14),
          const SizedBox(height: 12),
          _bar(double.infinity, 12),
          const SizedBox(height: 6),
          _bar(double.infinity, 12),
          const SizedBox(height: 12),
          _bar(60, 10),
        ],
      ),
    );
  }
}
