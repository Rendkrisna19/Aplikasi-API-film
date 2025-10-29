import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/omdb_api.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

const omdbKey = 'cc31bf62'; // ganti dengan key kamu

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = OmdbApi(omdbKey);

  // Data default (section)
  List<Movie> heroList = [];
  List<Movie> section1 = [];
  List<Movie> section2 = [];
  List<Movie> section3 = [];

  // Data search
  List<Movie> searchResults = [];
  bool searching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDefault();
  }

  Future<void> _loadDefault() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r1 = await api.search('popular trailer');
      final r2 = await api.search('marvel');
      final r3 = await api.search('batman');
      final r4 = await api.search('star');

      setState(() {
        heroList = r1.take(10).toList();
        section1 = r2.take(10).toList();
        section2 = r3.take(10).toList();
        section3 = r4.take(10).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searching = false;
      });
      return;
    }

    setState(() {
      searching = true;
      loading = true;
      error = null;
    });

    try {
      final res = await api.search(query);
      setState(() {
        searchResults = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieAPI (OMDb)'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadDefault,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDefault,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // 🔍 Search Box
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      onSubmitted: _searchMovies,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Cari film (mis. Interstellar, Spiderman...)',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFF151518),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  if (searching) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Text(
                        'Hasil Pencarian: ${_searchCtrl.text}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (searchResults.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('Film tidak ditemukan.'),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          itemCount: searchResults.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (_, i) {
                            final m = searchResults[i];
                            return MovieCard(
                              movie: m,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailPage(imdbID: m.imdbID),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ] else ...[
                    // ===== Hero Section =====
                    if (heroList.isNotEmpty)
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: heroList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final m = heroList[i];
                            final poster = m.poster != 'N/A' ? m.poster : null;
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailPage(imdbID: m.imdbID),
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (poster == null)
                                        Container(color: Colors.white12)
                                      else
                                        Image.network(poster,
                                            fit: BoxFit.cover),
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black54
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 12,
                                        right: 12,
                                        bottom: 12,
                                        child: Text(
                                          m.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 12,
                                                  color: Colors.black)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    _sectionTitle('Marvel Picks', c),
                    _movieRow(section1),
                    _sectionTitle('Batman Universe', c),
                    _movieRow(section2),
                    _sectionTitle('Star Classics', c),
                    _movieRow(section3),
                  ],
                ],
              ),
            ),
    );
  }

  Padding _sectionTitle(String title, ColorScheme c) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
        child: Row(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            Icon(Icons.chevron_right, color: c.primary),
          ],
        ),
      );

  Widget _movieRow(List<Movie> items) => SizedBox(
        height: 260,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final m = items[i];
            return MovieCard(
              movie: m,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(imdbID: m.imdbID),
                ),
              ),
            );
          },
        ),
      );
}
