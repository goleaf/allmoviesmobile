import 'package:allmovies_mobile/data/models/genre_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/genres_provider.dart';
import 'package:allmovies_mobile/presentation/screens/genres/genres_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _StubRepository extends TmdbRepository {
  _StubRepository() : super(apiKey: 'test');
}

class TestGenresProvider extends GenresProvider {
  TestGenresProvider() : super(_StubRepository());

  bool movieFetchCalled = false;
  bool tvFetchCalled = false;

  List<Genre> movieGenresOverride = const [];
  List<Genre> tvGenresOverride = const [];
  bool isLoadingMoviesOverride = false;
  bool isLoadingTvOverride = false;
  String? movieErrorOverride;
  String? tvErrorOverride;

  void emitMovieState({
    List<Genre>? genres,
    bool? loading,
    String? error,
  }) {
    if (genres != null) movieGenresOverride = genres;
    if (loading != null) isLoadingMoviesOverride = loading;
    movieErrorOverride = error;
    notifyListeners();
  }

  void emitTvState({
    List<Genre>? genres,
    bool? loading,
    String? error,
  }) {
    if (genres != null) tvGenresOverride = genres;
    if (loading != null) isLoadingTvOverride = loading;
    tvErrorOverride = error;
    notifyListeners();
  }

  @override
  List<Genre> get movieGenres => movieGenresOverride;

  @override
  List<Genre> get tvGenres => tvGenresOverride;

  @override
  Map<int, Genre> get movieGenreMap => {
        for (final genre in movieGenresOverride) genre.id: genre,
      };

  @override
  Map<int, Genre> get tvGenreMap => {
        for (final genre in tvGenresOverride) genre.id: genre,
      };

  @override
  bool get isLoadingMovies => isLoadingMoviesOverride;

  @override
  bool get isLoadingTv => isLoadingTvOverride;

  @override
  String? get movieError => movieErrorOverride;

  @override
  String? get tvError => tvErrorOverride;

  @override
  bool get hasMovieGenres => movieGenresOverride.isNotEmpty;

  @override
  bool get hasTvGenres => tvGenresOverride.isNotEmpty;

  @override
  Future<void> fetchMovieGenres({bool forceRefresh = false}) async {
    movieFetchCalled = true;
  }

  @override
  Future<void> fetchTvGenres({bool forceRefresh = false}) async {
    tvFetchCalled = true;
  }
}

Widget _buildTestApp(GenresProvider provider) {
  return MaterialApp(
    home: ChangeNotifierProvider<GenresProvider>.value(
      value: provider,
      child: const GenresScreen(),
    ),
  );
}

void main() {
  testWidgets('fetches genres on init', (tester) async {
    final provider = TestGenresProvider();

    await tester.pumpWidget(_buildTestApp(provider));
    await tester.pump();

    expect(provider.movieFetchCalled, isTrue);
    expect(provider.tvFetchCalled, isTrue);
  });

  testWidgets('shows loading indicator while fetching movie genres',
      (tester) async {
    final provider = TestGenresProvider();

    await tester.pumpWidget(_buildTestApp(provider));
    provider.emitMovieState(loading: true, genres: const []);
    provider.emitTvState(loading: false, genres: const []);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders genres list when data is available', (tester) async {
    final provider = TestGenresProvider();
    final genre = const Genre(id: 12, name: 'Action');

    await tester.pumpWidget(_buildTestApp(provider));
    provider.emitMovieState(loading: false, genres: [genre]);
    await tester.pump();

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('TMDB ID: 12'), findsOneWidget);
    expect(find.textContaining('Discover'), findsWidgets);
  });

  testWidgets('shows error banner when movie genres fallback is used',
      (tester) async {
    final provider = TestGenresProvider();
    final genre = const Genre(id: 5, name: 'Drama');

    await tester.pumpWidget(_buildTestApp(provider));
    provider.emitMovieState(
      genres: [genre],
      loading: false,
      error: 'Failed to load movie genres',
    );
    await tester.pump();

    expect(find.text('Failed to load movie genres'), findsOneWidget);
    expect(
      find.text(
        "We're showing fallback genres until TMDB responds.",
      ),
      findsOneWidget,
    );
  });
}
