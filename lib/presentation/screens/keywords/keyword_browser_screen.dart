import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/keyword_browser_provider.dart';
import '../../widgets/app_drawer.dart';

class KeywordBrowserScreen extends StatefulWidget {
  const KeywordBrowserScreen({super.key});

  static const routeName = '/keywords';

  @override
  State<KeywordBrowserScreen> createState() => _KeywordBrowserScreenState();
}

class _KeywordBrowserScreenState extends State<KeywordBrowserScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeywordBrowserProvider>().loadTrendingKeywords();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.keywords)),
      drawer: const AppDrawer(),
      body: Consumer<KeywordBrowserProvider>(
        builder: (context, provider, _) {
          return _KeywordBrowserBody(
            provider: provider,
            controller: _controller,
            localizations: localizations,
          );
        },
      ),
    );
  }
}

class _KeywordBrowserBody extends StatelessWidget {
  const _KeywordBrowserBody({
    required this.provider,
    required this.controller,
    required this.localizations,
  });

  final KeywordBrowserProvider provider;
  final TextEditingController controller;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.refreshAll,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200 &&
              provider.canLoadMore &&
              !provider.isLoadingMore &&
              !provider.isSearching) {
            provider.loadMore();
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _KeywordSearchField(
              controller: controller,
              provider: provider,
              hintText: localizations.t('keywords.search_hint'),
            ),
            const SizedBox(height: 24),
            _TrendingKeywordsSection(
              provider: provider,
              controller: controller,
              title: localizations.t('keywords.trending_title'),
              subtitle: localizations.t('keywords.trending_subtitle'),
            ),
            const SizedBox(height: 24),
            _SearchResultsSection(
              provider: provider,
              controller: controller,
              localizations: localizations,
            ),
          ],
        ),
      ),
    );
  }
}

class _KeywordSearchField extends StatelessWidget {
  const _KeywordSearchField({
    required this.controller,
    required this.provider,
    required this.hintText,
  });

  final TextEditingController controller;
  final KeywordBrowserProvider provider;
  final String hintText;

  void _performSearch(String value) {
    provider.search(value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            suffixIcon: provider.isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : hasText
                ? IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    onPressed: () {
                      controller.clear();
                      provider.clearSearch();
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
          onChanged: (text) {
            if (text.isEmpty && provider.hasQuery) {
              provider.clearSearch();
            }
          },
        );
      },
    );
  }
}

class _TrendingKeywordsSection extends StatelessWidget {
  const _TrendingKeywordsSection({
    required this.provider,
    required this.controller,
    required this.title,
    required this.subtitle,
  });

  final KeywordBrowserProvider provider;
  final TextEditingController controller;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        if (provider.isLoadingTrending)
          const Center(child: CircularProgressIndicator())
        else if (provider.trendingError != null)
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.trendingError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: provider.refreshTrendingKeywords,
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppStrings.retry),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (provider.trendingKeywords.isEmpty)
          Text(
            AppLocalizations.of(context).t('keywords.empty_trending'),
            style: theme.textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.trendingKeywords
                .map(
                  (keyword) => ActionChip(
                    label: Text(keyword.name),
                    onPressed: () {
                      controller.text = keyword.name;
                      provider.search(keyword.name);
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({
    required this.provider,
    required this.controller,
    required this.localizations,
  });

  final KeywordBrowserProvider provider;
  final TextEditingController controller;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildEmptyState() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.t('keywords.search_prompt'),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    Widget buildResults() {
      if (provider.isSearching && !provider.hasSearchResults) {
        return const Center(child: CircularProgressIndicator());
      }

      if (provider.searchError != null && !provider.hasSearchResults) {
        return Text(
          provider.searchError!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
      }

      if (!provider.hasSearchResults) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.t('keywords.empty_results'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              localizations.t('search.try_different_keywords'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...provider.searchResults.map(
            (keyword) => Card(
              child: ListTile(
                leading: const Icon(Icons.tag),
                title: Text(keyword.name),
                onTap: () {
                  controller.text = keyword.name;
                },
              ),
            ),
          ),
          if (provider.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.t('keywords.search_results_title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (!provider.hasQuery) buildEmptyState() else buildResults(),
      ],
    );
  }
}
