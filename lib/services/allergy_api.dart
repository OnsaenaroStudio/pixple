import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AllergyApiResult {
  final List<int> allergens;
  final bool cached;
  AllergyApiResult({required this.allergens, required this.cached});
}

class AllergyApi {
  static const _endpoint =
      'https://pixple-backend.vercel.app/api/gemini-api';

  static const _prompt = '(prompt)';

  static Future<AllergyApiResult> detect(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final b64 = base64Encode(bytes);
    final mime = _guessMime(imageFile.path);

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'img': 'data:$mime;base64,$b64',
        'prompt': _prompt,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('API 오류: HTTP ${res.statusCode} - ${res.body}');
    }

    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (json['code'] != 200) {
      throw Exception('응답 오류: code=${json['code']}');
    }

    final data = json['data'] as Map<String, dynamic>;
    final list = (data['allergens'] as List).map((e) => e as int).toList();
    return AllergyApiResult(
      allergens: list,
      cached: json['cached'] == true,
    );
  }

  static String _guessMime(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'image/jpeg';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }
}
