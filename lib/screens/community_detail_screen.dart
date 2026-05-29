import 'package:flutter/material.dart';
import '../models/community_models.dart';
import '../services/community_api.dart';
import '../theme/app_theme.dart';

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
  final _nameController = TextEditingController(text: 'PixpleDev');
  final _userIdController = TextEditingController(text: 'dev_local_001');

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<CommunityComment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    _userIdController.dispose();
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
    final userId = _userIdController.text.trim();
    final content = _commentController.text.trim();

    if (name.isEmpty || userId.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임, 유저ID, 댓글 내용을 입력해주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
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
    try {
      final ok = await CommunityApi.likeComment(commentId: c.id);
      if (!ok || !mounted) return;
      setState(() {
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;

    return Scaffold(
      appBar: AppBar(title: const Text('게시글')),
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
                              children: a.hashtags
                                  .map((t) => Chip(label: Text('#$t')))
                                  .toList(),
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
                      const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ))
                    else if (_error != null)
                      Text('댓글 로드 실패: $_error')
                    else if (_comments.isEmpty)
                      const Text('아직 댓글이 없습니다.')
                    else
                      ..._comments.map((c) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${c.userName} (${c.userId})',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(c.content),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('좋아요 ${c.likes}'),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _like(c),
                                      child: const Text('추천'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            hintText: '유저ID',
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
