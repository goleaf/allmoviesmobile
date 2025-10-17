import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/presentation/widgets/media_gallery_section.dart';
import 'package:allmovies_mobile/providers/media_gallery_provider.dart';

import '../test_support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaGallerySection', () {
    late _FakeMediaGalleryProvider provider;

    setUp(() {
      provider = _FakeMediaGalleryProvider(_buildMediaImages());
    });

    tearDown(() {
      provider.dispose();
    });

    Future<void> pumpSection(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<MediaGalleryProvider>.value(
          value: provider,
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Scaffold(
              body: MediaGallerySection(),
            ),
          ),
        ),
      );
      // Allow inherited widgets and initial build to complete.
      await tester.pump();
    }

    testWidgets('renders poster, backdrop, and still rows when images are available',
        (tester) async {
      await pumpSection(tester);

      expect(find.text('Images'), findsOneWidget);
      expect(find.text('Posters'), findsOneWidget);
      expect(find.text('Backdrops'), findsOneWidget);
      expect(find.text('Stills'), findsOneWidget);

      final horizontalLists = find.byWidgetPredicate(
        (widget) => widget is ListView && widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalLists, findsNWidgets(3));

      // The counter chip is rendered for each list to show the item counts.
      expect(find.text('2'), findsNWidgets(3));
    });

    testWidgets('shows progressive overlays and opens zoom dialog on tap',
        (tester) async {
      await pumpSection(tester);

      // The blurred preview layer should be present while the high-res image loads.
      expect(find.byType(ImageFiltered), findsWidgets);

      // The tinted progress overlay should also be visible during the initial frame.
      final progressOverlays = find.byWidgetPredicate((widget) {
        return widget is Container &&
            widget.decoration == null &&
            widget.color == Colors.black.withOpacity(0.08);
      });
      expect(progressOverlays, findsWidgets);

      final posterList = find.byWidgetPredicate(
        (widget) => widget is ListView && widget.scrollDirection == Axis.horizontal,
      ).first;

      final firstPosterTile = find.descendant(
        of: posterList,
        matching: find.byType(GestureDetector),
      ).first;

      await tester.tap(firstPosterTile);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });
}

MediaImages _buildMediaImages() {
  const posterAspect = 0.667;
  const backdropAspect = 16 / 9;
  const stillAspect = 1.5;

  ImageModel buildImage(String path, double aspect, {int width = 1000}) {
    final height = (width / aspect).round();
    return ImageModel(
      filePath: path,
      width: width,
      height: height,
      aspectRatio: aspect,
      voteAverage: 7.5,
      voteCount: 150,
    );
  }

  return MediaImages(
    posters: [
      buildImage('/poster_a.jpg', posterAspect),
      buildImage('/poster_b.jpg', posterAspect),
    ],
    backdrops: [
      buildImage('/backdrop_a.jpg', backdropAspect),
      buildImage('/backdrop_b.jpg', backdropAspect),
    ],
    stills: [
      buildImage('/still_a.jpg', stillAspect, width: 800),
      buildImage('/still_b.jpg', stillAspect, width: 800),
    ],
  );
}

class _FakeMediaGalleryProvider extends MediaGalleryProvider {
  _FakeMediaGalleryProvider(this._images) : super(FakeTmdbRepository());

  MediaImages _images;

  @override
  MediaImages? get images => _images;

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  String? get errorMessage => null;

  void updateImages(MediaImages images) {
    _images = images;
    notifyListeners();
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMovieImages(int movieId, {bool forceRefresh = false}) async {}

  @override
  Future<void> loadTvImages(int tvId, {bool forceRefresh = false}) async {}
}
