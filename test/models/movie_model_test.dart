import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie_model.dart';

void main() {
  group('MovieModel', () {
    test('stores basic information', () {
      const model = MovieModel(
        id: '1',
        title: 'Sample',
        genre: 'Action',
        year: 2024,
        description: 'Desc',
      );
      expect(model.title, 'Sample');
      expect(model.year, 2024);
    });
  });
}
