import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/presentation/widgets/person_combined_timeline.dart';
import 'package:allmovies_mobile/providers/person_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/test_wrapper.dart';

void main() {
  testWidgets('renders years in chronological order with group labels',
      (tester) async {
    final entries = [
      PersonCombinedTimelineEntry(
        year: '2023',
        groups: const [
          PersonCombinedTimelineMediaGroup(
            mediaType: 'movie',
            credits: [
              PersonCredit(id: 1, title: 'Recent Film'),
            ],
          ),
        ],
      ),
      PersonCombinedTimelineEntry(
        year: '2021',
        groups: const [
          PersonCombinedTimelineMediaGroup(
            mediaType: 'tv',
            credits: [
              PersonCredit(id: 2, name: 'Old Show'),
            ],
          ),
        ],
      ),
      PersonCombinedTimelineEntry(
        year: PersonCombinedTimelineEntry.unknownYear,
        groups: const [
          PersonCombinedTimelineMediaGroup(
            mediaType: 'other',
            credits: [
              PersonCredit(id: 3, title: 'Untitled Project'),
            ],
          ),
        ],
      ),
    ];

    await pumpTestApp(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: PersonCombinedTimeline(
            title: 'Timeline',
            emptyLabel: 'No data',
            entries: entries,
            careerStats: const [
              PersonCareerTimelineBucket(
                year: '2021',
                actingCredits: 1,
                crewCredits: 0,
              ),
              PersonCareerTimelineBucket(
                year: '2023',
                actingCredits: 1,
                crewCredits: 1,
              ),
            ],
          ),
        ),
      ),
    );

    final top2023 = tester.getTopLeft(find.text('2023')).dy;
    final top2021 = tester.getTopLeft(find.text('2021')).dy;
    expect(top2023, lessThan(top2021));

    expect(find.text('Movie'), findsOneWidget);
    expect(find.text('TV'), findsOneWidget);
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('Acting'), findsOneWidget);
    expect(find.text('Crew'), findsOneWidget);
  });

  testWidgets('shows empty state when entries are missing', (tester) async {
    await pumpTestApp(
      tester,
      Scaffold(
        body: PersonCombinedTimeline(
          title: 'Timeline',
          emptyLabel: 'No data',
          entries: const [],
          careerStats: const [],
        ),
      ),
    );

    expect(find.text('No data'), findsOneWidget);
  });
}
