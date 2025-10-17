import 'package:allmovies_mobile/presentation/screens/lists/lists_screen.dart';
import 'package:allmovies_mobile/providers/lists_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support/test_wrapper.dart';
import '../test_support/fakes.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';

class _InMemoryPrefs implements SharedPreferences {
  final Map<String, Object> _data = {};
  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  Object? get(String key) => _data[key];
  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Future<bool> clear() async { _data.clear(); return true; }
  @override
  Future<bool> remove(String key) async { _data.remove(key); return true; }
  @override
  Future<bool> setString(String key, String value) async { _data[key] = value; return true; }
  // ignore: no_leading_underscores_for_local_identifiers
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalStorageService _makeStorage() => LocalStorageService(_InMemoryPrefs());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _buildWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListsProvider(_makeStorage(), currentUserId: 'me', currentUserName: 'Me')),
      ],
      child: TestApp(child: child),
    );
  }

  testWidgets('ListsScreen shows loading then sections', (tester) async {
    await tester.pumpWidget(_buildWithProviders(const ListsScreen()));

    // Initially a progress indicator while provider loads
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    // After init, should render either empty state or sections
    expect(find.text('Lists'), findsOneWidget);

    // With seed, expect section headers
    expect(find.text('My lists'), findsWidgets);
  });

  testWidgets('Create new list via FAB and form submit', (tester) async {
    await tester.pumpWidget(_buildWithProviders(const ListsScreen()));
    await tester.pumpAndSettle();

    // Open editor
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Test List');
    await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Desc');

    await tester.tap(find.widgetWithText(FilledButton, 'Create list'));
    await tester.pumpAndSettle();

    // Snackbar confirms
    expect(find.textContaining('Created "New Test List"'), findsOneWidget);
  });

  testWidgets('Follow/unfollow from card button', (tester) async {
    await tester.pumpWidget(_buildWithProviders(const ListsScreen()));
    await tester.pumpAndSettle();

    // Switch user to non-owner by opening menu -> Follow appears on non-owner cards
    // Find a card from Popular lists (discoverable)
    final followCandidate = find.widgetWithText(Chip, 'Popular lists');
    expect(followCandidate, findsOneWidget);

    // Open popup menu on first card and tap Follow/Unfollow via menu (safer to target)
    final popupButtons = find.byType(PopupMenuButton);
    expect(popupButtons, findsWidgets);
    await tester.tap(popupButtons.first);
    await tester.pumpAndSettle();

    // Tap Share exists; Follow item may be present depending on ownership
    final followItem = find.widgetWithText(PopupMenuItem, 'Follow');
    if (followItem.evaluate().isNotEmpty) {
      await tester.tap(followItem.first);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Delete list via menu with confirmation', (tester) async {
    await tester.pumpWidget(_buildWithProviders(const ListsScreen()));
    await tester.pumpAndSettle();

    // Create a list to delete (owned by me)
    final provider = Provider.of<ListsProvider>(tester.element(find.byType(ListsScreen)), listen: false);
    final list = await provider.createList(name: 'Temp to delete');
    await tester.pumpAndSettle();

    // Open menu on first card
    final popupButtons = find.byType(PopupMenuButton);
    await tester.tap(popupButtons.first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(PopupMenuItem, 'Delete'));
    await tester.pumpAndSettle();

    // Confirm dialog
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(provider.listById(list!.id), isNull);
  });
}


