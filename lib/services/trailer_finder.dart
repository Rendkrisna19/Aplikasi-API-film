import 'dart:convert';
import 'package:http/http.dart' as http;

/// Mengembalikan videoId (11 char) untuk query trailer.
/// Contoh query: "Inception 2010 official trailer"
Future<String?> findYoutubeTrailerId(String query) async {
  // pakai m.youtube.com supaya HTML lebih ringan
  final uri = Uri.https('m.youtube.com', '/results', {'search_query': query});
  final res = await http.get(uri, headers: {
    'User-Agent': 'Mozilla/5.0 (Mobile; Flutter)',
  });
  if (res.statusCode != 200) return null;

  final body = res.body;

  // 1) Pola JSON yang umum di HTML
  final reg1 = RegExp(r'"videoId":"([a-zA-Z0-9_-]{11})"');
  final m1 = reg1.firstMatch(body);
  if (m1 != null) return m1.group(1);

  // 2) Fallback dari URL
  final reg2 = RegExp(r'watch\?v=([a-zA-Z0-9_-]{11})');
  final m2 = reg2.firstMatch(body);
  if (m2 != null) return m2.group(1);

  // 3) Fallback ekstrem dari initialData (kadang di JSON encoded)
  try {
    final decoded = utf8.decode(res.bodyBytes);
    final m3 = reg1.firstMatch(decoded);
    if (m3 != null) return m3.group(1);
  } catch (_) {}

  return null;
}
