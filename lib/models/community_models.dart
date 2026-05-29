class CommunityArticle {
  final int id;
  final String title;
  final String content;
  final List<String> hashtags;
  final DateTime createdAt;

  CommunityArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.hashtags,
    required this.createdAt,
  });

  factory CommunityArticle.fromJson(Map<String, dynamic> json) {
    final rawTags = json['article_hash_tag'];
    List<String> tags = [];
    if (rawTags is List) {
      tags = rawTags.map((e) => e.toString()).toList();
    } else if (rawTags is String && rawTags.trim().isNotEmpty) {
      tags = rawTags.split(',').map((e) => e.trim()).toList();
    }

    return CommunityArticle(
      id: (json['id'] as num).toInt(),
      title: (json['article_title'] ?? '').toString(),
      content: (json['article_content'] ?? '').toString(),
      hashtags: tags,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class CommunityListResponse {
  final int page;
  final List<CommunityArticle> articles;

  CommunityListResponse({required this.page, required this.articles});

  factory CommunityListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['articles'] as List? ?? [])
        .map((e) => CommunityArticle.fromJson(e as Map<String, dynamic>))
        .toList();

    return CommunityListResponse(
      page: (json['page'] as num?)?.toInt() ?? 1,
      articles: list,
    );
  }
}
