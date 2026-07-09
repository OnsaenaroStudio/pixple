import 'package:flutter/material.dart';
import '../models/community_models.dart';
import '../services/community_api.dart';
import '../services/local_identity.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityArticle article;

  const CommunityDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final _commentController = TextEditingController();
  final _nameController = TextEditingController(text: 'PixpleUser');

  String? _myUserId;
  bool _loading = true;
  bool _submitting = false;
  bool _deleting = false;
  bool _deletingArticle = false;
  String? _error;
  List<CommunityComment> _comments = [];
  Set<int> _likedCommentIds = {};

  @override
  void initState() {
    super.initState();
    _initIdentity();
    _loadComments();
  }

  Future<void> _initIdentity() async {
    final id = await LocalIdentity.getOrCreateUserId();
    final name = await LocalIdentity.getUserName();
    final liked = await _loadLikedCommentIds(id);
    if (!mounted) return;
    setState(() {
      _myUserId = id;
      _nameController.text = name;
      _likedCommentIds = liked;
    });
  }

  Future<Set<int>> _loadLikedCommentIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('liked_comments_$userId');
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as List).map((e) => e as int).toSet();
  }

  Future<void> _saveLikedCommentIds() async {
    final userId = _myUserId;
    if (userId == null || userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'liked_comments_$userId',
      jsonEncode(_likedCommentIds.toList()),
    );
  }

  Future<bool> _confirmDialog(String title, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _isMyArticle => _myUserId != null && _myUserId!.isNotEmpty && widget.article.userId == _myUserId;

  Future<void> _deleteArticle() async {
    if (_deletingArticle) return;

    final myId = _myUserId;
    if (myId == null || myId.isEmpty || !_isMyArticle) {
      _showSnack('본인이 작성한 게시글만 삭제할 수 있어요.');
      return;
    }

    if (!await _confirmDialog('게시글 삭제', '이 게시글을 삭제할까요?')) return;

    setState(() => _deletingArticle = true);
    try {
      final success = await CommunityApi.deleteArticle(
        articleId: widget.article.id,
        userId: myId,
      );
      if (!mounted) return;

      if (success) {
        _showSnack('게시글이 삭제되었습니다.');
        Navigator.pop(context, true);
      } else {
        _showSnack('게시글 삭제에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('게시글 삭제 실패: $e');
    } finally {
      if (mounted) setState(() => _deletingArticle = false);
    }
  }


  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list =
          await CommunityApi.fetchComments(articleId: widget.article.id);
      setState(() => _comments = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    if (_submitting) return;

    final name = _nameController.text.trim();
    final content = _commentController.text.trim();
    final userId = _myUserId;

    if (name.isEmpty || content.isEmpty) {
      _showSnack('닉네임과 댓글 내용을 입력해주세요.');
      return;
    }

    if (userId == null || userId.isEmpty) {
      _showSnack('사용자 식별값 초기화 중입니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    setState(() => _submitting = true);

    try {
      await LocalIdentity.setUserName(name);

      final created = await CommunityApi.writeComment(
        articleId: widget.article.id,
        userId: userId,
        userName: name,
        content: content,
      );

      if (!mounted) return;

      if (created != null) {
        setState(() {
          _comments = [created, ..._comments];
          _commentController.clear();
        });
      } else {
        _showSnack('댓글 등록에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('댓글 등록 실패: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _like(CommunityComment c) async {
    if (_likedCommentIds.contains(c.id)) {
      _showSnack('이미 좋아요를 눌렀어요.');
      return;
    }

    try {
      final ok = await CommunityApi.likeComment(commentId: c.id);
      if (!ok || !mounted) return;

      setState(() {
        _likedCommentIds.add(c.id);
        _comments = _comments
            .map((e) => e.id == c.id
                ? CommunityComment(
                    id: e.id,
                    articleId: e.articleId,
                    userName: e.userName,
                    userId: e.userId,
                    content: e.content,
                    likes: e.likes + 1,
                    createdAt: e.createdAt,
                  )
                : e)
            .toList();
      });

      await _saveLikedCommentIds();
    } catch (_) {}
  }

  Future<void> _deleteComment(CommunityComment c) async {
    if (_deleting) return;

    final myId = _myUserId;
    if (myId == null || myId.isEmpty || c.userId != myId) return;

    if (!await _confirmDialog('댓글 삭제', '이 댓글을 삭제할까요?')) return;

    setState(() => _deleting = true);
    try {
      final ok = await CommunityApi.deleteComment(
        commentId: c.id,
        userId: myId,
      );

      if (!mounted) return;

      if (ok) {
        setState(() => _comments.removeWhere((e) => e.id == c.id));
      } else {
        _showSnack('댓글 삭제 실패');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('댓글 삭제 실패: $e');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
          if (_isMyArticle)
            IconButton(
              onPressed: _deletingArticle ? null : _deleteArticle,
              icon: const Icon(Icons.delete_outline),
              tooltip: '게시글 삭제',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadComments,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _ArticleCard(article: a),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text('댓글', style: textTheme.titleLarge),
                        const SizedBox(width: 8),
                        Text(
                          '${_comments.length}',
                          style: textTheme.titleMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      _EmptyNotice(message: '댓글 로드 실패: $_error')
                    else if (_comments.isEmpty)
                      const _EmptyNotice(message: '아직 댓글이 없어요.\n첫 댓글을 남겨보세요!')
                    else
                      ..._comments.map(
                        (c) => _CommentTile(
                          comment: c,
                          isMine: _myUserId != null && c.userId == _myUserId,
                          isLiked: _likedCommentIds.contains(c.id),
                          onLike: () => _like(c),
                          onDelete: _deleting ? null : () => _deleteComment(c),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _CommentInputBar(
              nameController: _nameController,
              commentController: _commentController,
              submitting: _submitting,
              onSubmit: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final CommunityArticle article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.hashtags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: article.hashtags
                  .map((t) => Chip(
                        label: Text('#$t'),
                        backgroundColor: Colors.white,
                        labelStyle: textTheme.bodySmall
                            ?.copyWith(color: AppColors.primary),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          Text(article.title, style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            article.content,
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final bool isMine;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.isMine,
    required this.isLiked,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.userName,
                  style: textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isMine)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '내 댓글',
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(
                onPressed: isLiked ? null : onLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                ),
                label: Text('${comment.likes}'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const Spacer(),
              if (isMine)
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('삭제'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  final String message;

  const _EmptyNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController commentController;
  final bool submitting;
  final VoidCallback onSubmit;

  const _CommentInputBar({
    required this.nameController,
    required this.commentController,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.nav,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: '닉네임',
              isDense: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(Icons.person_outline,
                  size: 20, color: AppColors.textSecondary),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '댓글을 입력하세요',
                    isDense: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: submitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(64, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('등록'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
