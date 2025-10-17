import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/presentation/widgets/media_gallery_section.dart';
import 'package:allmovies_mobile/presentation/widgets/media_image.dart';
import 'package:allmovies_mobile/providers/media_gallery_provider.dart';

import '../test_support/test_wrapper.dart';

class _FakeMediaGalleryProvider extends ChangeNotifier
    implements MediaGalleryProvider {
  _FakeMediaGalleryProvider({
    MediaImages? images,
    bool isLoading = false,
    String? errorMessage,
  })  : _images = images,
        _isLoading = isLoading,
        _errorMessage = errorMessage;

  MediaImages? _images;
  bool _isLoading;
  String? _errorMessage;
  bool refreshInvoked = false;

  void setLoading() {
    _isLoading = true;
    _errorMessage = null;
    _images = null;
    notifyListeners();
  }

  void setEmpty() {
    _isLoading = false;
    _errorMessage = null;
    _images = MediaImages.empty();
    notifyListeners();
  }

  void setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  void setImages(MediaImages images) {
    _isLoading = false;
    _errorMessage = null;
    _images = images;
    notifyListeners();
  }

  @override
  MediaImages? get images => _images;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  bool get hasError => _errorMessage != null;

  @override
  Future<void> refresh() async {
    refreshInvoked = true;
  }

  @override
  Future<void> loadMovieImages(int movieId, {bool forceRefresh = false}) async {}

  @override
  Future<void> loadTvImages(int tvId, {bool forceRefresh = false}) async {}
}

Future<String> _localized(String key) async {
  final loc = AppLocalizations(const Locale('en'));
  await loc.load();
  return loc.t(key);
}

Future<void> _pumpGallery(
  WidgetTester tester,
  _FakeMediaGalleryProvider provider, {
  bool settle = true,
}) async {
  await pumpTestApp(
    tester,
    ChangeNotifierProvider<MediaGalleryProvider>.value(
      value: provider,
      child: const Scaffold(body: MediaGallerySection()),
    ),
    settle: settle,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaGallerySection', () {
    late _FakeMediaGalleryProvider provider;

    setUp(() {
      provider = _FakeMediaGalleryProvider();
    });

    testWidgets('shows loading indicator while provider is loading', (tester) async {
      provider.setLoading();

      final imagesLabel = await _localized('movie.images');
      await _pumpGallery(tester, provider);

      expect(find.text(imagesLabel), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders nothing when provider has no images', (tester) async {
      provider.setEmpty();

      final imagesLabel = await _localized('movie.images');
      await _pumpGallery(tester, provider);

      expect(find.byType(MediaGallerySection), findsOneWidget);
      expect(find.byType(Text), findsNothing);
      expect(find.text(imagesLabel), findsNothing);
      expect(find.byType(MediaImage), findsNothing);
    });

    testWidgets('renders error message and retry action on failure', (tester) async {
      provider.setError('Network failed');

      final imagesLabel = await _localized('movie.images');
      final errorTitle = await _localized('errors.load_failed');
      final retryLabel = await _localized('common.retry');

      await _pumpGallery(tester, provider);

      expect(find.text(imagesLabel), findsOneWidget);
      expect(find.text(errorTitle), findsOneWidget);
      expect(find.text('Network failed'), findsOneWidget);

      await tester.tap(find.text(retryLabel));
      await tester.pump();

      expect(provider.refreshInvoked, isTrue);
    });

    testWidgets('renders gallery rows with placeholders and progress overlays', (tester) async {
      final imagesLabel = await _localized('movie.images');
      final postersLabel = await _localized('movie.posters');
      final backdropsLabel = await _localized('movie.backdrops');

      provider.setImages(
        MediaImages(
          posters: [
            const ImageModel(
              filePath: '',
              width: 500,
              height: 750,
              aspectRatio: 0.67,
            ),
          ],
          backdrops: [
            const ImageModel(
              filePath: '/backdrop.jpg',
              width: 1280,
              height: 720,
              aspectRatio: 16 / 9,
            ),
          ],
        ),
      );

      await _pumpGallery(tester, provider, settle: false);
      await tester.pump();

      expect(find.text(imagesLabel), findsOneWidget);
      expect(find.text(postersLabel), findsOneWidget);
      expect(find.text(backdropsLabel), findsOneWidget);

      final placeholderContainers = tester.widgetList(find.byType(Container)).where((widget) {
        final container = widget as Container;
        return container.color == Colors.grey[300];
      }).toList();
      expect(placeholderContainers, isNotEmpty);

      final progressFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CircularProgressIndicator && widget.strokeWidth == 3,
      );
      expect(progressFinder, findsOneWidget);
    });

    testWidgets('opens fullscreen viewer when tapping a thumbnail and closes it', (tester) async {
      provider.setImages(
        MediaImages(
          posters: [
            const ImageModel(
              filePath: '/poster.jpg',
              width: 500,
              height: 750,
              aspectRatio: 0.67,
            ),
          ],
        ),
      );

      await _pumpGallery(tester, provider);

      final thumbnailFinder = find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.child is AspectRatio,
      );
      expect(thumbnailFinder, findsWidgets);

      await tester.tap(thumbnailFinder.first);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(MediaImage), findsWidgets);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });
}
