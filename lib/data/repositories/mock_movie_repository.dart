import '../models/movie_model.dart';

class MockMovieRepository {
  MockMovieRepository._();

  static final List<MovieModel> _movies = List.unmodifiable([
    const MovieModel(
      id: 'movie_1',
      title: 'Midnight Chase',
      genre: 'Action',
      year: 2024,
      description:
          'A relentless detective uncovers a conspiracy after a high-speed pursuit goes wrong.',
    ),
    const MovieModel(
      id: 'movie_2',
      title: 'Starlight Echoes',
      genre: 'Sci-Fi',
      year: 2023,
      description:
          'An astronaut stranded on a distant moon must communicate with Earth through ancient ruins.',
    ),
    const MovieModel(
      id: 'movie_3',
      title: 'Hidden Pages',
      genre: 'Mystery',
      year: 2022,
      description:
          'A librarian discovers a lost journal that reveals the secrets of her quiet town.',
    ),
    const MovieModel(
      id: 'movie_4',
      title: 'The Last Sonata',
      genre: 'Drama',
      year: 2021,
      description:
          'A reclusive pianist returns to the stage to honor a promise made decades ago.',
    ),
    const MovieModel(
      id: 'movie_5',
      title: 'Crimson Shore',
      genre: 'Thriller',
      year: 2020,
      description:
          'Vacationers on a remote island uncover a smuggling operation beneath the waves.',
    ),
    const MovieModel(
      id: 'movie_6',
      title: 'Sketches of Tomorrow',
      genre: 'Animation',
      year: 2019,
      description:
          'An aspiring inventor brings her drawings to life and learns to control her creations.',
    ),
    const MovieModel(
      id: 'movie_7',
      title: 'Winds of Aster',
      genre: 'Fantasy',
      year: 2018,
      description:
          'A young shepherd discovers he can command the weather to protect his homeland.',
    ),
    const MovieModel(
      id: 'movie_8',
      title: 'Neon Bites',
      genre: 'Horror',
      year: 2017,
      description:
          'Late-night food critics discover a secret ingredient that turns patrons into predators.',
    ),
    const MovieModel(
      id: 'movie_9',
      title: 'Parallel Lines',
      genre: 'Romance',
      year: 2016,
      description:
          'Two architects competing for the same contract must collaborate to succeed.',
    ),
    const MovieModel(
      id: 'movie_10',
      title: 'Echoes in Clay',
      genre: 'Documentary',
      year: 2015,
      description:
          'Archaeologists unearth a civilization that mastered sound-based communication.',
    ),
  ]);

  static final Map<String, MovieModel> _moviesById = {
    for (final movie in _movies) movie.id: movie,
  };

  static List<MovieModel> getMovies() => _movies;

  static MovieModel? getById(String id) => _moviesById[id];

  static List<MovieModel> getByIds(Iterable<String> ids) {
    final result = <MovieModel>[];
    for (final id in ids) {
      final movie = _moviesById[id];
      if (movie != null) {
        result.add(movie);
      }
    }
    return result;
  }
}
