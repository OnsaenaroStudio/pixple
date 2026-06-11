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
    final key = 'liked_comments_$userId';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    final list = (jsonDecode(raw) as List).map((e) => e as int).toSet();
    return list;
  }

  Future<void> _saveLikedCommentIds() async {
    final userId = _myUserId;
    if (userId == null || userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'liked_comments_$userId';
    await prefs.setString(key, jsonEncode(_likedCommentIds.toList()));
  }

  Future<void> _deleteArticle() async {
    if (_deletingArticle) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('이 게시글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _deletingArticle = true);
    try {
      final success = await CommunityApi.deleteArticle(articleId: widget.article.id);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 삭제되었습니다.')),
        );
        Navigator.pop(context, true); // 목록 화면에 "삭제됨" 알림
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 삭제 실패: $e')),
      );
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
      final list = await CommunityApi.fetchComments(articleId: widget.article.id);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임과 댓글 내용을 입력해주세요.')),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 식별값 초기화 중입니다. 잠시 후 다시 시도해주세요.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 등록에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 등록 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _like(CommunityComment c) async {
    if (_likedCommentIds.contains(c.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 좋아요를 눌렀어요.')),
      );
      return;
    }

    try {
      final ok = await CommunityApi.likeComment(commentId: c.id); // 기존 API 그대로
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
    if (myId == null || c.userId != myId) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('이 댓글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      final ok = await CommunityApi.deleteComment(commentId: c.id);
      if (!mounted) return;

      if (ok) {
        setState(() {
          _comments.removeWhere((e) => e.id == c.id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 삭제 실패')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (a.hashtags.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: a.hashtags.map((t) => Chip(label: Text('#$t'))).toList(),
                            ),
                          if (a.hashtags.isNotEmpty) const SizedBox(height: 10),
                          Text(
                            a.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            a.content,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '댓글',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                      Text('댓글 로드 실패: $_error')
                    else if (_comments.isEmpty)
                      const Text('아직 댓글이 없습니다.')
                    else
                      ..._comments.map(
                        (c) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${c.userName} (${c.userId})',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(c.content),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('좋아요 ${c.likes}'),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _likedCommentIds.contains(c.id) ? null : () => _like(c),
                                    child: Text(_likedCommentIds.contains(c.id) ? '추천 완료' : '추천'),
                                  ),
                                  if (_myUserId != null && c.userId == _myUserId) ...[
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: _deleting ? null : () => _deleteComment(c),
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: '닉네임',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '댓글을 입력하세요',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submitComment,
                        child: Text(_submitting ? '등록중' : '등록'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
