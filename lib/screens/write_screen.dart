import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/community_api.dart';
import '../services/local_identity.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _hashtagController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  List<String> _parseHashtags(String raw) {
    final normalized = raw.replaceAll('\n', ',').replaceAll(' ', '');
    return normalized
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.startsWith('#') ? e.substring(1) : e)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _parseHashtags(_hashtagController.text);

    if (title.isEmpty) {
      _showSnack('제목을 입력해주세요.');
      return;
    }

    if (content.isEmpty) {
      _showSnack('내용을 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = await LocalIdentity.getOrCreateUserId();
      final articleId = await CommunityApi.writeArticle(
        title: title,
        content: content,
        userId: userId,
        hashtags: tags,
      );

      if (!mounted) return;

      if (articleId == null) {
        _showSnack('업로드에 실패했어요. 다시 시도해주세요.');
        return;
      }

      _showSnack('글이 등록되었습니다.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('업로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('글 쓰기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('제목', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      enabled: !_isSubmitting,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        hintText: '글 제목을 입력하세요',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('내용', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      enabled: !_isSubmitting,
                      minLines: 10,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: '내용을 입력하세요',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('해시태그', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hashtagController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        hintText: '쉼표로 구분해 입력 (예: 알레르기, 레시피)',
                        prefixIcon: Icon(Icons.tag,
                            size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text('업로드 중...'),
                        ],
                      )
                    : const Text('업로드'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
