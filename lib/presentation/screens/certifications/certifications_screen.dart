import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/certification_model.dart';
import '../../../providers/certifications_provider.dart';
import '../../widgets/app_drawer.dart';

/// Dedicated screen that visualizes TMDB certification catalogs for movies and TV.
class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  /// Route identifier registered in `MaterialApp.routes`.
  static const routeName = '/certifications';

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _didLoadInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialData) {
      return;
    }

    final provider = context.read<CertificationsProvider>();
    _searchController
      ..text = provider.searchQuery
      ..addListener(() {
        provider.updateSearchQuery(_searchController.text);
      });

    // Trigger the initial fetch after the first frame so the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadAll();
    });

    _didLoadInitialData = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.t('certifications.title')),
      ),
      drawer: const AppDrawer(),
      body: Consumer<CertificationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasResults) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && !provider.hasResults) {
            return _ErrorView(
              message: provider.errorMessage!,
              buttonLabel: localizations.t('common.retry'),
              onRetry: provider.loadAll,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _HeaderSection(localizations: localizations),
                const SizedBox(height: 12),
                _SearchField(
                  controller: _searchController,
                  hintText: localizations.t('certifications.search_hint'),
                ),
                const SizedBox(height: 12),
                _CountryDropdown(localizations: localizations),
                const SizedBox(height: 12),
                _MediaTypeSelector(localizations: localizations),
                const SizedBox(height: 16),
                _ResultsSummary(localizations: localizations),
                const SizedBox(height: 12),
                _CertificationsList(localizations: localizations),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.t('certifications.subtitle'),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.t('certifications.instructions'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasQuery = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            suffixIcon: hasQuery
                ? IconButton(
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clear,
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  const _CountryDropdown({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificationsProvider>();

    final countries = provider.countries;
    final items = countries
        .map(
          (country) => DropdownMenuItem<String?>(
            value: country.code,
            child: Text(country.englishName),
          ),
        )
        .toList();

    return InputDecorator(
      decoration: InputDecoration(
        labelText: localizations.t('certifications.filter_country'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: provider.selectedCountryCode,
          hint: Text(localizations.t('certifications.filter_all_countries')),
          isExpanded: true,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(localizations.t('certifications.filter_all_countries')),
            ),
            ...items,
          ],
          onChanged: provider.selectCountry,
        ),
      ),
    );
  }
}

class _MediaTypeSelector extends StatelessWidget {
  const _MediaTypeSelector({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificationsProvider>();
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text(localizations.t('certifications.media_movies')),
          selected: provider.activeMediaType == CertificationMediaType.movie,
          onSelected: (_) =>
              context.read<CertificationsProvider>().updateMediaType(CertificationMediaType.movie),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text(localizations.t('certifications.media_tv')),
          selected: provider.activeMediaType == CertificationMediaType.tv,
          onSelected: (_) =>
              context.read<CertificationsProvider>().updateMediaType(CertificationMediaType.tv),
        ),
        const SizedBox(width: 8),
        if (provider.selectedCountryCode != null)
          Chip(
            avatar: const Icon(Icons.flag_outlined, size: 16),
            label: Text(
              provider.countryNameOf(provider.selectedCountryCode!),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _ResultsSummary extends StatelessWidget {
  const _ResultsSummary({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificationsProvider>();
    final entries = provider.filteredEntries;
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.certifications.length);

    final templateKey = provider.activeMediaType == CertificationMediaType.movie
        ? 'certifications.result_movies'
        : 'certifications.result_tv';
    final summary = localizations.t(templateKey).replaceFirst('{count}', '$total');

    return Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _CertificationsList extends StatelessWidget {
  const _CertificationsList({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificationsProvider>();
    final entries = provider.filteredEntries;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Icon(Icons.report_outlined, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text(
              localizations.t('certifications.empty'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final entry in entries)
          _CertificationCountryCard(
            data: entry,
            localizations: localizations,
          ),
      ],
    );
  }
}

class _CertificationCountryCard extends StatelessWidget {
  const _CertificationCountryCard({
    required this.data,
    required this.localizations,
  });

  final CertificationCountryData data;
  final AppLocalizations localizations;

  /// Generates a short age guidance description by inspecting the rating label.
  String _buildAgeGuidance(Certification certification) {
    final rating = certification.certification.trim();
    final meaning = certification.meaning.trim();
    final digitsRegExp = RegExp(r'(\d{1,2})');
    final digitMatch = digitsRegExp.firstMatch(rating) ?? digitsRegExp.firstMatch(meaning);

    if (digitMatch != null) {
      return localizations
          .t('certifications.age_template')
          .replaceFirst('{age}', digitMatch.group(0)!);
    }

    final lower = rating.toLowerCase();
    if (lower == 'g' || lower.contains('general')) {
      return localizations.t('certifications.age_all');
    }
    if (lower.contains('pg')) {
      return localizations.t('certifications.age_pg');
    }
    if (lower.contains('r') || lower.contains('restricted')) {
      return localizations.t('certifications.age_restricted');
    }
    if (lower.contains('nc') || lower.contains('x')) {
      return localizations.t('certifications.age_no_children');
    }

    return localizations.t('certifications.age_generic');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.countryName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        localizations
                            .t('certifications.country_code')
                            .replaceFirst('{code}', data.countryCode),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final cert in data.certifications)
              _CertificationTile(
                certification: cert,
                guidance: _buildAgeGuidance(cert),
                localizations: localizations,
              ),
          ],
        ),
      ),
    );
  }
}

class _CertificationTile extends StatelessWidget {
  const _CertificationTile({
    required this.certification,
    required this.guidance,
    required this.localizations,
  });

  final Certification certification;
  final String guidance;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.primaryContainer,
            ),
            alignment: Alignment.center,
            child: Text(
              certification.certification.isEmpty
                  ? localizations.t('certifications.not_applicable')
                  : certification.certification,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.meaning,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  guidance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.buttonLabel,
    required this.onRetry,
  });

  final String message;
  final String buttonLabel;
  final Future<void> Function({bool forceRefresh})? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => onRetry?.call(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
