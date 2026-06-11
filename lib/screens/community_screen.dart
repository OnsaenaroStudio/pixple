import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../services/community_api.dart';
import '../models/community_models.dart';
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _goWrite() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WriteScreen()),
    );
    await _load(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.grid_view_rounded, size: 28),
                    color: AppColors.textPrimary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _WriteButton(onTap: _goWrite),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const _PostSkeletonCard(),
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 40),
          Text(
            '불러오기에 실패했어요.\n$_error',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _load(page: 1),
            child: const Text('다시 시도'),
          ),
        ],
      );
    }

    if (_articles.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: const [
          SizedBox(height: 40),
          Text(
            '아직 게시글이 없어요.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _PostCard(article: _articles[i],
        onTap: () async {
          final deleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityDetailScreen(article: _articles[i]),
            ),
          );

          if (deleted == true) {
            await _load(page: 1); // 또는 _load(page: _page)
          }
          await _load(page: _page);
        }
      ),
    );
  }
}

class _WriteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WriteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit_outlined, size: 18, color: AppColors.navIconActive),
            SizedBox(width: 6),
            Text(
              '글 쓰기',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
          ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.hashtags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: article.hashtags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.photoButton,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$t',
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ))
                    .toList(),
              ),
            if (article.hashtags.isNotEmpty) const SizedBox(height: 10),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              _dateText(article.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostSkeletonCard extends StatelessWidget {
  const _PostSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.photoButton,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.photoButton,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.photoButton,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
