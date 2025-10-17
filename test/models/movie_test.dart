import 'package:flutter_test/flutter_test.dart';
import 'package:allmovies_mobile/data/models/movie.dart';

void main() {
  group('Movie Model Tests', () {
    test('should create Movie from valid JSON', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'overview': 'A test movie description',
        'poster_path': '/test_poster.jpg',
        'backdrop_path': '/test_backdrop.jpg',
        'release_date': '2024-01-15',
        'vote_average': 8.5,
        'vote_count': 1000,
        'popularity': 25.5,
        'adult': false,
        'genre_ids': [28, 12, 16],
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 123);
      expect(movie.title, 'Test Movie');
      expect(movie.overview, 'A test movie description');
      expect(movie.posterPath, '/test_poster.jpg');
      expect(movie.backdropPath, '/test_backdrop.jpg');
      expect(movie.releaseDate, '2024-01-15');
      expect(movie.voteAverage, 8.5);
      expect(movie.voteCount, 1000);
      expect(movie.popularity, 25.5);
      expect(movie.adult, false);
      expect(movie.genreIds, [28, 12, 16]);
    });

    test('should handle TV show JSON (name instead of title)', () {
      final json = {
        'id': 456,
        'name': 'Test TV Show',
        'media_type': 'tv',
        'first_air_date': '2024-02-20',
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 456);
      expect(movie.title, 'Test TV Show');
      expect(movie.mediaType, 'tv');
      expect(movie.releaseDate, '2024-02-20');
    });

    test('should generate correct poster URL', () {
      final movie = Movie(id: 1, title: 'Test', posterPath: '/test.jpg');

      expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/test.jpg');
    });

    test('should return null poster URL when path is null', () {
      final movie = Movie(id: 1, title: 'Test');

      expect(movie.posterUrl, null);
    });

    test('should generate correct backdrop URL', () {
      final movie = Movie(id: 1, title: 'Test', backdropPath: '/backdrop.jpg');

      expect(movie.backdropUrl, 'https://image.tmdb.org/t/p/w780/backdrop.jpg');
    });

    test('should extract release year from date', () {
      final movie = Movie(id: 1, title: 'Test', releaseDate: '2024-03-15');

      expect(movie.releaseYear, '2024');
    });

    test('should return null year when date is null', () {
      final movie = Movie(id: 1, title: 'Test');

      expect(movie.releaseYear, null);
    });

    test('should return correct media label for TV', () {
      final movie = Movie(id: 1, title: 'Test', mediaType: 'tv');

      expect(movie.mediaLabel, 'TV');
    });

    test('should return correct media label for Movie', () {
      final movie = Movie(id: 1, title: 'Test', mediaType: 'movie');

      expect(movie.mediaLabel, 'Movie');
    });

    test('should format rating correctly', () {
      final movie = Movie(id: 1, title: 'Test', voteAverage: 8.567);

      expect(movie.formattedRating, '8.6 ★');
    });

    test('should return N/A for zero rating', () {
      final movie = Movie(id: 1, title: 'Test', voteAverage: 0);

      expect(movie.formattedRating, 'N/A');
    });

    test('should format vote count with K suffix for thousands', () {
      final movie = Movie(id: 1, title: 'Test', voteCount: 5432);

      expect(movie.formattedVoteCount, '5.4K votes');
    });

    test('should format vote count without K for hundreds', () {
      final movie = Movie(id: 1, title: 'Test', voteCount: 500);

      expect(movie.formattedVoteCount, '500 votes');
    });

    test('should return genre names from genre IDs', () {
      final movie = Movie(id: 1, title: 'Test', genreIds: [28, 12, 16]);

      final genres = movie.genres;

      expect(genres, contains('Action'));
      expect(genres, contains('Adventure'));
      expect(genres, contains('Animation'));
      expect(genres.length, 3);
    });

    test('should handle empty genre list', () {
      final movie = Movie(id: 1, title: 'Test');

      expect(movie.genres, isEmpty);
    });

    test('should handle unknown genre IDs', () {
      final movie = Movie(id: 1, title: 'Test', genreIds: [99999]);

      expect(movie.genres, isEmpty);
    });

    test('should default adult to false', () {
      final movie = Movie(id: 1, title: 'Test');

      expect(movie.adult, false);
    });

    test('should handle empty or whitespace-only overview as null', () {
      final json1 = {'id': 1, 'title': 'Test', 'overview': ''};

      final json2 = {'id': 1, 'title': 'Test', 'overview': '   '};

      final movie1 = Movie.fromJson(json1);
      final movie2 = Movie.fromJson(json2);

      expect(movie1.overview, null);
      expect(movie2.overview, null);
    });

    test('should trim whitespace from title and overview', () {
      final json = {
        'id': 1,
        'title': '  Test Movie  ',
        'overview': '  Test description  ',
      };

      final movie = Movie.fromJson(json);

      expect(movie.title, 'Test Movie');
      expect(movie.overview, 'Test description');
    });
  });
}
