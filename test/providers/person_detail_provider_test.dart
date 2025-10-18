import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/person_detail_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePersonRepository extends TmdbRepository {
  _FakePersonRepository(this.detail) : super(apiKey: 'test');

  final PersonDetail detail;

  @override
  Future<PersonDetail> fetchPersonDetails(
    int personId, {
    bool forceRefresh = false,
  }) async {
    return detail;
  }
}

void main() {
  group('PersonDetailProvider combined timeline', () {
    test('groups credits chronologically by year and media type', () async {
      final detail = PersonDetail(
        id: 1,
        name: 'Demo',
        combinedCredits: PersonCredits(
          cast: [
            PersonCredit(
              id: 10,
              mediaType: 'movie',
              title: 'Latest Movie',
              releaseDate: '2023-05-12',
              character: 'Hero',
            ),
            PersonCredit(
              id: 11,
              mediaType: 'tv',
              name: 'Recent Show',
              firstAirDate: '2022-09-01',
              character: 'Lead',
            ),
          ],
          crew: [
            PersonCredit(
              id: 12,
              mediaType: 'movie',
              title: 'Classic Film',
              releaseDate: '2018-03-04',
              job: 'Director',
            ),
            PersonCredit(
              id: 13,
              mediaType: 'tv',
              name: 'Classic Series',
              firstAirDate: '2018-06-10',
              job: 'Producer',
            ),
            const PersonCredit(
              id: 14,
              mediaType: null,
              title: 'Unscheduled Project',
            ),
          ],
        ),
      );

      final provider = PersonDetailProvider(_FakePersonRepository(detail), 1);
      await provider.load();

      final timeline = provider.combinedCreditsTimeline;
      expect(
        timeline.map((entry) => entry.year).toList(),
        [
          '2023',
          '2022',
          '2018',
          PersonCombinedTimelineEntry.unknownYear,
        ],
      );

      final entry2018 =
          timeline.firstWhere((entry) => entry.year == '2018');
      final movieGroup = entry2018.groups
          .firstWhere((group) => group.mediaType == 'movie');
      final tvGroup =
          entry2018.groups.firstWhere((group) => group.mediaType == 'tv');
      expect(movieGroup.credits.single.displayTitle, 'Classic Film');
      expect(tvGroup.credits.single.displayTitle, 'Classic Series');

      final unknownEntry = timeline
          .firstWhere((entry) => entry.year == PersonCombinedTimelineEntry.unknownYear);
      expect(unknownEntry.groups.single.mediaType, 'other');
      expect(unknownEntry.groups.single.credits.single.displayTitle,
          'Unscheduled Project');
    });

    test('creates a single unknown entry when dates are missing', () async {
      final detail = PersonDetail(
        id: 1,
        name: 'Demo',
        combinedCredits: const PersonCredits(
          cast: [
            PersonCredit(
              id: 21,
              mediaType: 'movie',
              title: 'Mystery Film',
            ),
          ],
          crew: [],
        ),
      );

      final provider = PersonDetailProvider(_FakePersonRepository(detail), 1);
      await provider.load();

      final timeline = provider.combinedCreditsTimeline;
      expect(timeline, hasLength(1));
      final entry = timeline.single;
      expect(entry.year, PersonCombinedTimelineEntry.unknownYear);
      expect(entry.groups.single.mediaType, 'other');
      expect(entry.groups.single.credits, hasLength(1));
    });

    test('builds career timeline buckets with acting and crew counts', () async {
      final detail = PersonDetail(
        id: 1,
        name: 'Demo',
        combinedCredits: PersonCredits(
          cast: [
            PersonCredit(
              id: 31,
              mediaType: 'movie',
              title: 'Early Acting Role',
              releaseDate: '2010-01-15',
            ),
            PersonCredit(
              id: 32,
              mediaType: 'tv',
              name: 'Recent Series',
              firstAirDate: '2022-09-20',
            ),
          ],
          crew: [
            PersonCredit(
              id: 41,
              mediaType: 'movie',
              title: 'Early Crew Role',
              releaseDate: '2010-06-10',
            ),
            PersonCredit(
              id: 42,
              mediaType: 'movie',
              title: 'Latest Crew Project',
              releaseDate: '2023-02-01',
            ),
            const PersonCredit(
              id: 43,
              mediaType: 'movie',
              title: 'Unscheduled Crew Project',
            ),
          ],
        ),
      );

      final provider = PersonDetailProvider(_FakePersonRepository(detail), 1);
      await provider.load();

      final buckets = provider.careerTimelineBuckets;
      expect(
        buckets.map((bucket) => bucket.year).toList(),
        ['2010', '2022', '2023', PersonCombinedTimelineEntry.unknownYear],
      );

      final earlyBucket = buckets.firstWhere((bucket) => bucket.year == '2010');
      expect(earlyBucket.actingCredits, 1);
      expect(earlyBucket.crewCredits, 1);

      final recentActing = buckets.firstWhere((bucket) => bucket.year == '2022');
      expect(recentActing.actingCredits, 1);
      expect(recentActing.crewCredits, 0);

      final unknownBucket = buckets
          .firstWhere((bucket) => bucket.year == PersonCombinedTimelineEntry.unknownYear);
      expect(unknownBucket.total, 1);
      expect(unknownBucket.crewCredits, 1);
    });
  });
}
