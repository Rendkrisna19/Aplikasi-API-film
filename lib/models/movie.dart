class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String poster; 
  final String type;   

  // detail
  final String? plot;
  final String? genre;
  final String? released;
  final String? runtime;
  final String? imdbRating;
  final String? actors;
  final String? director;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
    required this.type,
    this.plot,
    this.genre,
    this.released,
    this.runtime,
    this.imdbRating,
    this.actors,
    this.director,
  });

  factory Movie.fromSearchJson(Map<String, dynamic> j) => Movie(
        imdbID: j['imdbID'] ?? '',
        title: j['Title'] ?? '',
        year: j['Year'] ?? '',
        poster: j['Poster'] ?? 'N/A',
        type: j['Type'] ?? '',
      );

  factory Movie.fromDetailJson(Map<String, dynamic> j) => Movie(
        imdbID: j['imdbID'] ?? '',
        title: j['Title'] ?? '',
        year: j['Year'] ?? '',
        poster: j['Poster'] ?? 'N/A',
        type: j['Type'] ?? '',
        plot: j['Plot'],
        genre: j['Genre'],
        released: j['Released'],
        runtime: j['Runtime'],
        imdbRating: j['imdbRating'],
        actors: j['Actors'],
        director: j['Director'],
      );
}
