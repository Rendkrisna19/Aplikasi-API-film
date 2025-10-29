import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class OmdbApi {
  OmdbApi(this.apiKey);
  final String apiKey;

  Future<List<Movie>> search(String query, {int page = 1}) async {
    final uri = Uri.https('www.omdbapi.com', '/', {
      'apikey': apiKey,
      's': query,
      'page': '$page',
      // type: movie/series  (opsional)
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['Response'] == 'False') return [];
    final List arr = json['Search'] ?? [];
    return arr.map((e) => Movie.fromSearchJson(e)).toList();
  }

  Future<Movie?> byId(String imdbID) async {
    final uri = Uri.https('www.omdbapi.com', '/', {
      'apikey': apiKey,
      'i': imdbID,
      'plot': 'full',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['Response'] == 'False') return null;
    return Movie.fromDetailJson(json);
  }
}
