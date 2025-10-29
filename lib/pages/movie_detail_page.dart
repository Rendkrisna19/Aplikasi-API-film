import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/omdb_api.dart';
import '../services/trailer_finder.dart';
import 'trailer_player_page.dart';
import 'package:url_launcher/url_launcher.dart';

const omdbKey = 'cc31bf62';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.imdbID});
  final String imdbID;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final api = OmdbApi(omdbKey);
  Movie? movie;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { movie = null; error = null; });
    try {
      final m = await api.byId(widget.imdbID);
      if (m == null) throw Exception('Film tidak ditemukan');
      setState(() => movie = m);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _playTrailer() async {
    if (movie == null) return;
    final query = '${movie!.title} ${movie!.year} official trailer ${movie!.imdbID}';
    final id = await findYoutubeTrailerId(query);

    if (id != null && !kIsWeb) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => TrailerPlayerPage(videoId: id, title: movie!.title),
      ));
      return;
    }

    // fallback: buka pencarian YouTube di browser / web
    final url = Uri.https('www.youtube.com', '/results', {'search_query': query});
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    if (error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      );
    }
    if (movie == null) {
      return Scaffold(
  appBar: AppBar(),
  body: Center(child: Text('Error: $error')),
);
    }

    final poster = movie!.poster != 'N/A' ? movie!.poster : null;

    return Scaffold(
      appBar: AppBar(title: Text(movie!.title)),
      body: ListView(
        children: [
          // header
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16/9,
                child: poster == null
                    ? Container(color: Colors.white12)
                    : CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover),
              ),
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
              Positioned(
                left: 14, right: 14, bottom: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: poster == null
                          ? Container(width: 80, height: 120, color: Colors.white12)
                          : CachedNetworkImage(imageUrl: poster, width: 80, height: 120, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${movie!.title} (${movie!.year})',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Wrap(
              spacing: 8, runSpacing: -6,
              children: [
                if ((movie!.genre ?? '').isNotEmpty)
                  ...movie!.genre!.split(',').map((g) => Chip(label: Text(g.trim()))),
                Chip(avatar: const Icon(Icons.timer, size: 16), label: Text(movie!.runtime ?? '-')),
                Chip(avatar: const Icon(Icons.event, size: 16), label: Text(movie!.released ?? '-')),
                Chip(avatar: const Icon(Icons.star, size: 16), label: Text('IMDb ${movie!.imdbRating ?? '-'}')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sinopsis', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(movie!.plot ?? '-'),
                const SizedBox(height: 12),
                Text('Sutradara: ${movie!.director ?? '-'}'),
                const SizedBox(height: 4),
                Text('Pemeran: ${movie!.actors ?? '-'}'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _playTrailer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Tonton Trailer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
