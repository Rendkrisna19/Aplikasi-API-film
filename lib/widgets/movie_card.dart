import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/movie.dart';

const _fallbackKey = 'cc31bf62'; // atau import dari tempat kamu simpan

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, this.onTap});
  final Movie movie;
  final VoidCallback? onTap;

  String? _posterUrl() {
    // 1) pakai Poster jika ada
    if (movie.poster.isNotEmpty && movie.poster != 'N/A') return movie.poster;
    // 2) fallback: thumbnail dari OMDb image endpoint (butuh apikey)
    if (movie.imdbID.isNotEmpty) {
      return 'https://img.omdbapi.com/?i=${movie.imdbID}&h=600&apikey=$_fallbackKey';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final poster = _posterUrl();

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 130, // tetap 130 agar konsisten grid horizontal
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: poster == null
                    ? Container(
                        color: Colors.white12,
                        child: const Icon(Icons.image_not_supported_rounded),
                      )
                    : CachedNetworkImage(
                        imageUrl: poster,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.white10),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Judul (maks 2 baris biar tidak overflow)
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 2),
            // Subjudul kecil
            Text(
              '${movie.year} • ${movie.type.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
