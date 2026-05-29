import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community_models.dart';

class CommunityApi {
  static const _host = 'pixple-backend.vercel.app';

  static Uri _communityUri(int page) => Uri.https(_host, '/api/community', {
        'page': '$page',
      });

  static Future<CommunityListResponse> fetchArticles({int page = 1}) async {
    final res = await http.get(
      _communityUri(page),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('게시글 목록 조회 실패: ${res.statusCode}');
    }
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return CommunityListResponse.fromJson(jsonMap);
  }

  static Future<int?> writeArticle({
    required String title,
    required String content,
    List<String>? hashtags,
  }) async {
    final uri = Uri.https(_host, '/api/community/write');
    final body = {
      'article_title': title,
      'article_content': content,
      'article_hash_tag': hashtags ?? <String>[],
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('게시글 등록 실패: ${res.statusCode}');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final ok = jsonMap['is_suc'] == true;
    if (!ok) return null;
    return (jsonMap['article_id'] as num?)?.toInt();
  }

  static Future<List<CommunityComment>> fetchComments({
    required int articleId,
  }) async {
    final uri = Uri.https(_host, '/api/community/comment', {
      'article_id': '$articleId',
    });

    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('댓글 조회 실패: ${res.statusCode}');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (jsonMap['comments'] as List? ?? [])
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  static Future<CommunityComment?> writeComment({
    required int articleId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final uri = Uri.https(_host, '/api/community/comment/write');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'article_id': articleId,
        'user_id': userId,
        'user_name': userName,
        'content': content,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('댓글 등록 실패: ${res.statusCode}');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    if (jsonMap['is_suc'] != true) return null;

    final c = jsonMap['comment'] as Map<String, dynamic>?;
    if (c == null) return null;
    return CommunityComment.fromJson(c);
  }

  static Future<bool> likeComment({required int commentId}) async {
    final uri = Uri.https(_host, '/api/community/comment/like');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'comment_id': commentId}),
    );

    if (res.statusCode != 200) {
      throw Exception('좋아요 실패: ${res.statusCode}');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return jsonMap['success'] == true;
  }
}
