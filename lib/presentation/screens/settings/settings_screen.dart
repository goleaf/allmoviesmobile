import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/accessibility_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/watch_region_provider.dart';
// duplicate import removed
import '../../../core/utils/service_locator.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/preferences_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('settings.title'))),
      body: ListView(
        children: [
          _SettingsHeader(title: l.t('settings.appearance')),
          _ThemeTile(),
          _SettingsHeader(title: l.t('settings.accessibility')),
          const _HighContrastTile(),
          const _ColorBlindPaletteTile(),
          const _TextScaleTile(),
          const _FocusIndicatorsTile(),
          const _KeyboardNavigationTile(),
          _SettingsHeader(title: l.t('settings.localization')),
          _LanguageTile(),
          _RegionTile(),
          _SettingsHeader(title: l.t('settings.content')),
          _IncludeAdultTile(),
          _DefaultSortTile(),
          _MinScoreTile(),
          _MinVoteCountTile(),
          _CertificationCountryTile(),
          _CertificationValueTile(),
          _SettingsHeader(title: l.t('settings.media')),
          // _ImageQualityTile(),
          _SettingsHeader(title: l.t('settings.cache')),
          _ClearCacheTile(),
          _ClearSearchHistoryTile(),
          _SettingsHeader(title: l.t('settings.about')),
          _StaticInfoTile(
            icon: Icons.info_outline,
            title: l.t('settings.appVersion'),
            value: '1.0.0',
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;

  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StaticInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StaticInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l.t('settings.theme')),
      subtitle: Text(themeProvider.getThemeModeName(themeProvider.themeMode)),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const _ThemeDialog(),
        );
      },
    );
  }
}

class _ThemeDialog extends StatelessWidget {
  const _ThemeDialog();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return AlertDialog(
      title: Text(l.t('settings.chooseTheme')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((mode) {
          return RadioListTile<AppThemeMode>(
            title: Text(themeProvider.getThemeModeName(mode)),
            value: mode,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.t('common.cancel')),
        ),
      ],
    );
  }
}

class _HighContrastTile extends StatelessWidget {
  const _HighContrastTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AccessibilityProvider>();

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.contrast),
      title: Text(l.t('settings.highContrast')),
      subtitle: Text(
        provider.highContrast
            ? l.t('settings.highContrastEnabled')
            : l.t('settings.highContrastDisabled'),
      ),
      value: provider.highContrast,
      onChanged: (value) => provider.toggleHighContrast(value),
    );
  }
}

class _ColorBlindPaletteTile extends StatelessWidget {
  const _ColorBlindPaletteTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AccessibilityProvider>();

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.palette),
      title: Text(l.t('settings.colorBlindFriendly')),
      subtitle: Text(l.t('settings.colorBlindFriendlyDescription')),
      value: provider.colorBlindFriendlyPalette,
      onChanged: (value) => provider.toggleColorBlindFriendlyPalette(value),
    );
  }
}

class _TextScaleTile extends StatelessWidget {
  const _TextScaleTile();

  static const Map<double, String> _labels = {
    0.9: 'settings.textScaleSmall',
    1.0: 'settings.textScaleNormal',
    1.2: 'settings.textScaleLarge',
    1.35: 'settings.textScaleExtraLarge',
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AccessibilityProvider>();
    final currentLabelKey = _labels.entries
        .firstWhere(
          (entry) => (provider.textScaleFactor - entry.key).abs() < 0.01,
          orElse: () => const MapEntry(1.0, 'settings.textScaleNormal'),
        )
        .value;

    return ListTile(
      leading: const Icon(Icons.text_increase),
      title: Text(l.t('settings.textScale')),
      subtitle: Text(l.t(currentLabelKey)),
      onTap: () => showDialog(
        context: context,
        builder: (context) => _TextScaleDialog(
          values: _labels,
          currentFactor: provider.textScaleFactor,
        ),
      ),
    );
  }
}

class _TextScaleDialog extends StatelessWidget {
  const _TextScaleDialog({
    required this.values,
    required this.currentFactor,
  });

  final Map<double, String> values;
  final double currentFactor;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AccessibilityProvider>();

    return AlertDialog(
      title: Text(l.t('settings.chooseTextScale')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: values.entries.map((entry) {
          return RadioListTile<double>(
            title: Text(l.t(entry.value)),
            value: entry.key,
            groupValue: currentFactor,
            onChanged: (value) {
              if (value != null) {
                provider.setTextScaleFactor(value);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.t('common.cancel')),
        ),
      ],
    );
  }
}

class _FocusIndicatorsTile extends StatelessWidget {
  const _FocusIndicatorsTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AccessibilityProvider>();

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.center_focus_strong),
      title: Text(l.t('settings.focusIndicators')),
      subtitle: Text(l.t('settings.focusIndicatorsDescription')),
      value: provider.showFocusIndicators,
      onChanged: (value) => provider.toggleFocusIndicators(value),
    );
  }
}

class _KeyboardNavigationTile extends StatelessWidget {
  const _KeyboardNavigationTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AccessibilityProvider>();

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.keyboard),
      title: Text(l.t('settings.keyboardNavigation')),
      subtitle: Text(l.t('settings.keyboardNavigationDescription')),
      value: provider.enableKeyboardNavigation,
      onChanged: (value) => provider.toggleKeyboardNavigation(value),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l.t('settings.language')),
      subtitle: Text(localeProvider.getLanguageName(localeProvider.locale)),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const _LanguageDialog(),
        );
      },
    );
  }
}

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    return AlertDialog(
      title: Text(l10n.t('settings.chooseLanguage')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppLocalizations.supportedLocales.map((locale) {
          return RadioListTile<Locale>(
            title: Text(localeProvider.getLanguageName(locale)),
            value: locale,
            groupValue: localeProvider.locale,
            onChanged: (value) {
              if (value != null) {
                localeProvider.setLocale(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.t('common.cancel')),
        ),
      ],
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final regionProvider = context.watch<WatchRegionProvider>();

    return ListTile(
      leading: const Icon(Icons.public),
      title: Text(l.t('settings.region')),
      subtitle: Text(regionProvider.getRegionName(regionProvider.region)),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const _RegionDialog(),
        );
      },
    );
  }
}

class _RegionDialog extends StatelessWidget {
  const _RegionDialog();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final regionProvider = context.watch<WatchRegionProvider>();

    return AlertDialog(
      title: Text(l.t('settings.chooseRegion')),
      content: SizedBox(
        width: 360,
        child: ListView(
          shrinkWrap: true,
          children: WatchRegionProvider.supportedRegions.map((r) {
            final code = r['code']!;
            final name = r['name']!;
            return RadioListTile<String>(
              title: Text(name),
              value: code,
              groupValue: regionProvider.region,
              onChanged: (value) async {
                if (value != null) {
                  await regionProvider.setRegion(value);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.t('common.cancel')),
        ),
      ],
    );
  }
}

// Removed duplicate _IncludeAdultTile definition

class _ClearCacheTile extends StatelessWidget {
  const _ClearCacheTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.delete_sweep_outlined),
      title: Text(l.t('settings.clear_cache')),
      onTap: () async {
        final cache = getIt<CacheService>();
        cache.clear();
        await cache.clearPersistent();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.t('settings.cache_cleared'))),
          );
        }
      },
    );
  }
}

class _ClearSearchHistoryTile extends StatelessWidget {
  const _ClearSearchHistoryTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.history_toggle_off),
      title: Text(l.t('search.clear_history')),
      onTap: () async {
        final storage = getIt<LocalStorageService>();
        await storage.clearSearchHistory();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.t('common.done'))));
        }
      },
    );
  }
}

class _IncludeAdultTile extends StatelessWidget {
  const _IncludeAdultTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();

    return SwitchListTile(
      secondary: const Icon(Icons.explicit_outlined),
      title: Text(l.t('settings.include_adult')),
      subtitle: Text(l.t('settings.include_adult_subtitle')),
      value: prefs.includeAdult,
      onChanged: (value) => prefs.setIncludeAdult(value),
    );
  }
}

class _DefaultSortTile extends StatelessWidget {
  const _DefaultSortTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();
    final current = prefs.defaultDiscoverSortRaw;

    String labelFor(String raw) {
      switch (raw) {
        case 'popularity.desc':
          return l.t('sort.popularity_desc');
        case 'vote_average.desc':
          return l.t('sort.rating_desc');
        case 'release_date.desc':
          return l.t('sort.release_date_desc');
        case 'title.asc':
          return l.t('sort.title_asc');
        default:
          return raw;
      }
    }

    return ListTile(
      leading: const Icon(Icons.sort),
      title: Text(l.t('settings.default_sort')),
      subtitle: Text(labelFor(current)),
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l.t('settings.default_sort')),
            children: [
              _SortOption(
                raw: 'popularity.desc',
                label: l.t('sort.popularity_desc'),
              ),
              _SortOption(
                raw: 'vote_average.desc',
                label: l.t('sort.rating_desc'),
              ),
              _SortOption(
                raw: 'release_date.desc',
                label: l.t('sort.release_date_desc'),
              ),
              _SortOption(raw: 'title.asc', label: l.t('sort.title_asc')),
            ],
          ),
        );
        if (selected != null && selected.isNotEmpty) {
          await prefs.setDefaultDiscoverSortRaw(selected);
        }
      },
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({required this.raw, required this.label});

  final String raw;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, raw),
      child: Text(label),
    );
  }
}

class _MinScoreTile extends StatelessWidget {
  const _MinScoreTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();
    final current = prefs.defaultMinUserScore;

    return ListTile(
      leading: const Icon(Icons.star_rate_outlined),
      title: Text(l.t('settings.min_user_score')),
      subtitle: Text(current.toStringAsFixed(1)),
      onTap: () async {
        final controller = TextEditingController(
          text: current.toStringAsFixed(1),
        );
        final selected = await showDialog<double>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.t('settings.min_user_score')),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(hintText: '0.0 - 10.0'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.t('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  Navigator.pop(context, value);
                },
                child: Text(l.t('common.done')),
              ),
            ],
          ),
        );
        if (selected != null) {
          await prefs.setDefaultMinUserScore(selected);
        }
      },
    );
  }
}

class _MinVoteCountTile extends StatelessWidget {
  const _MinVoteCountTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();
    final current = prefs.defaultMinVoteCount;

    return ListTile(
      leading: const Icon(Icons.how_to_vote_outlined),
      title: Text(l.t('settings.min_vote_count')),
      subtitle: Text('$current'),
      onTap: () async {
        final controller = TextEditingController(text: '$current');
        final selected = await showDialog<int>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.t('settings.min_vote_count')),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0 - 10000'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.t('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  final value = int.tryParse(controller.text);
                  Navigator.pop(context, value);
                },
                child: Text(l.t('common.done')),
              ),
            ],
          ),
        );
        if (selected != null) {
          await prefs.setDefaultMinVoteCount(selected);
        }
      },
    );
  }
}

class _ImageQualityTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();
    final current = prefs.imageQuality;

    String label(String q) {
      switch (q) {
        case 'low':
          return l.t('images.quality_low');
        case 'medium':
          return l.t('images.quality_medium');
        case 'high':
          return l.t('images.quality_high');
        case 'original':
          return l.t('images.quality_original');
        default:
          return q;
      }
    }

    return ListTile(
      leading: const Icon(Icons.image_outlined),
      title: Text(l.t('settings.image_quality')),
      subtitle: Text(label(current)),
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l.t('settings.image_quality')),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'low'),
                child: Text(l.t('images.quality_low')),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'medium'),
                child: Text(l.t('images.quality_medium')),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'high'),
                child: Text(l.t('images.quality_high')),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'original'),
                child: Text(l.t('images.quality_original')),
              ),
            ],
          ),
        );
        if (selected != null) {
          await prefs.setImageQuality(selected);
        }
      },
    );
  }
}

class _CertificationCountryTile extends StatelessWidget {
  const _CertificationCountryTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();
    final current = prefs.certificationCountry ?? '';

    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: Text(l.t('settings.certification_country')),
      subtitle: Text(current.isEmpty ? l.t('common.none') : current),
      onTap: () async {
        final controller = TextEditingController(text: current);
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.t('settings.certification_country')),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'US, GB, DE...'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.t('common.cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: Text(l.t('common.done')),
              ),
            ],
          ),
        );
        await prefs.setCertificationCountry(
          (selected != null && selected.isNotEmpty) ? selected : null,
        );
      },
    );
  }
}

class _CertificationValueTile extends StatelessWidget {
  const _CertificationValueTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesProvider>();
    final current = prefs.certificationValue ?? '';

    return ListTile(
      leading: const Icon(Icons.badge_outlined),
      title: Text(l.t('settings.certification')),
      subtitle: Text(current.isEmpty ? l.t('common.none') : current),
      onTap: () async {
        final controller = TextEditingController(text: current);
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.t('settings.certification')),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., PG-13, R, TV-MA',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.t('common.cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: Text(l.t('common.done')),
              ),
            ],
          ),
        );
        await prefs.setCertificationValue(
          (selected != null && selected.isNotEmpty) ? selected : null,
        );
      },
    );
  }
}
