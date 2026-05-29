import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/community_api.dart'; // 추가

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

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _parseHashtags(_hashtagController.text);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final articleId = await CommunityApi.writeArticle(
        title: title,
        content: content,
        hashtags: tags,
      );

      if (!mounted) return;

      if (articleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업로드에 실패했어요. 다시 시도해주세요.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 완료 (ID: $articleId)')),
      );

      Navigator.pop(context, true); // 성공 플래그 반환
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _BackButton(
                onTap: _isSubmitting ? null : () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleField(controller: _titleController),
                    const SizedBox(height: 16),
                    _ContentField(controller: _contentController),
                    const SizedBox(height: 16),
                    _HashtagField(controller: _hashtagController),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _UploadButton(
                        onTap: _isSubmitting ? null : _submit,
                        isLoading: _isSubmitting,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backButton,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 4),
              Text(
                '뒤로가기',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  const _TitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: '글 제목',
          hintStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _ContentField extends StatelessWidget {
  final TextEditingController controller;
  const _ContentField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: '글 내용',
          hintStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _HashtagField extends StatelessWidget {
  final TextEditingController controller;
  const _HashtagField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
      decoration: InputDecoration(
        hintText: '# 해시 태그 입력 (쉼표로 구분)',
        hintStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _UploadButton({
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLoading) ...[
                const Icon(Icons.edit_outlined, size: 20, color: AppColors.navIconActive),
                const SizedBox(width: 8),
              ],
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (isLoading) const SizedBox(width: 8),
              Text(
                isLoading ? '업로드 중...' : '업로드',
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
