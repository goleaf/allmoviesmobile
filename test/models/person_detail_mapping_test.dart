import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/person_detail_model.dart';

void main() {
  group('PersonDetail mapping', () {
    test('fromJson maps nested structures and defaults', () {
      final json =
          jsonDecode('''{
        "id": 42,
        "name": "  Keanu Reeves  ",
        "profile_path": "/path.jpg",
        "biography": "  Actor  ",
        "known_for_department": "  Acting  ",
        "birthday": "1964-09-02",
        "place_of_birth": "  Beirut  ",
        "gender": 2,
        "also_known_as": ["  KR  ", 123, null],
        "popularity": 12.5,
        "external_ids": {"imdb_id": "nm0000206"},
        "images": {"profiles": [{"file_path": "/p.jpg", "aspect_ratio": 0.66, "height": 100, "width": 150}]},
        "tagged_images": {"results": [{"file_path": "/t.jpg", "aspect_ratio": 0.66, "height": 100, "width": 150, "media": {"id": 1, "title": "John Wick"}}]},
        "combined_credits": {"cast": [{"id": 1, "title": "Speed"}], "crew": []},
        "movie_credits": {"cast": [], "crew": [{"id": 2, "job": "Director"}]},
        "tv_credits": {"cast": [], "crew": []},
        "translations": {"translations": [{"iso_3166_1": "US", "iso_639_1": "en", "name": "English", "english_name": "English", "data": {"biography": "Bio"}}]}
      }''')
              as Map<String, dynamic>;

      final detail = PersonDetail.fromJson(json);
      expect(detail.id, 42);
      expect(detail.name, 'Keanu Reeves');
      expect(detail.profilePath, '/path.jpg');
      expect(detail.biography, 'Actor');
      expect(detail.knownForDepartment, 'Acting');
      expect(detail.placeOfBirth, 'Beirut');
      expect(detail.alsoKnownAs, ['  KR  ']);
      expect(detail.profiles, isNotEmpty);
      expect(detail.taggedImages, isNotEmpty);
      expect(detail.combinedCredits.cast.first.id, 1);
      expect(detail.movieCredits.crew.first.id, 2);
      expect(detail.translations.first.biography, 'Bio');
    });

    test('PersonCredit helpers are robust', () {
      final credit = PersonCredit.fromJson({
        'id': '7',
        'title': '  ',
        'name': '  Sample  ',
        'release_date': '2020-01-02',
      });

      expect(credit.id, 7);
      expect(credit.displayTitle, 'Sample');
      expect(credit.releaseYear, '2020');
    });

    test('PersonTaggedMedia titleOrName prefers non-empty trimmed value', () {
      final media = PersonTaggedMedia.fromJson({
        'id': 1,
        'title': '  ',
        'name': ' Name ',
      });

      expect(media.titleOrName, 'Name');
    });
  });
}
