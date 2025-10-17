import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/watch_region_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _SettingsHeader(title: l10n.appearance),
          const _ThemeTile(),
          _SettingsHeader(title: l10n.localization),
          const _LanguageTile(),
          const _RegionTile(),
          _SettingsHeader(title: l10n.about),
          _StaticInfoTile(
            icon: Icons.info_outline,
            title: l10n.appVersion,
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
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
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
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l10n.theme),
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
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    
    return AlertDialog(
      title: Text(l10n.chooseTheme),
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
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
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
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    
    return AlertDialog(
      title: Text(l10n.chooseLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: LocaleProvider.supportedLocales.map((locale) {
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
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final regionProvider = context.watch<WatchRegionProvider>();

    return ListTile(
      leading: const Icon(Icons.public),
      title: Text(l10n.region),
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
    final l10n = AppLocalizations.of(context)!;
    final regionProvider = context.watch<WatchRegionProvider>();

    return AlertDialog(
      title: Text(l10n.chooseRegion),
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
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
