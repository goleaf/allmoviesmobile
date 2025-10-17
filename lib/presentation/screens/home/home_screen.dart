import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  static const int _movieCount = 10;
  late final List<String> _movieTitles;
  late final List<String> _normalizedMovieTitles;
  late final List<int> _allMovieIndices;
  late List<int> _visibleMovieIndices;

  @override
  void initState() {
    super.initState();
    _movieTitles = List<String>.generate(_movieCount, (index) => 'Movie ${index + 1}');
    _normalizedMovieTitles = List<String>.generate(
      _movieCount,
      (index) => _movieTitles[index].toLowerCase(),
    );
    _allMovieIndices = List<int>.generate(_movieCount, (index) => index);
    _visibleMovieIndices = _allMovieIndices;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.movie_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  isDense: true,
                ),
                onChanged: (value) {
                  final query = value.trim().toLowerCase();
                  if (query.isEmpty) {
                    if (!identical(_visibleMovieIndices, _allMovieIndices)) {
                      setState(() {
                        _visibleMovieIndices = _allMovieIndices;
                      });
                    }
                    return;
                  }

                  final matches = <int>[];
                  for (var i = 0; i < _normalizedMovieTitles.length; i++) {
                    if (_normalizedMovieTitles[i].contains(query)) {
                      matches.add(i);
                    }
                  }

                  setState(() {
                    _visibleMovieIndices = matches;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${authProvider.currentUser?.fullName ?? "Guest"}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _visibleMovieIndices.length,
                itemBuilder: (context, index) {
                  final movieIndex = _visibleMovieIndices[index];
                  return _MovieCard(index: movieIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final int index;

  const _MovieCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.movie_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Movie ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '2024 • Action',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
