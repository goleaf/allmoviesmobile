import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/tmdb_v4_endpoint.dart';
import '../../../data/tmdb_v4_repository.dart';
import '../../../providers/tmdb_v4_reference_provider.dart';
import '../../widgets/app_drawer.dart';

class TmdbV4ReferenceScreen extends StatelessWidget {
  const TmdbV4ReferenceScreen({super.key});

  static const routeName = '/explorer/v4';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TmdbV4ReferenceProvider(context.read<TmdbV4Repository>()),
      child: const _TmdbV4ReferenceView(),
    );
  }
}

class _TmdbV4ReferenceView extends StatelessWidget {
  const _TmdbV4ReferenceView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TmdbV4ReferenceProvider>();
    final groups = provider.groups;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tmdbV4Reference)),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _EndpointGroupCard(group: group);
        },
      ),
    );
  }
}

class _EndpointGroupCard extends StatelessWidget {
  const _EndpointGroupCard({required this.group});

  final TmdbV4EndpointGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.cloud_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...group.endpoints.map(
                (endpoint) => _EndpointTile(endpoint: endpoint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndpointTile extends StatelessWidget {
  const _EndpointTile({required this.endpoint});

  final TmdbV4Endpoint endpoint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TmdbV4ReferenceProvider>();
    final state = provider.stateFor(endpoint);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: endpoint.supportsExecution
              ? () => provider.execute(endpoint)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MethodChip(method: endpoint.method),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            endpoint.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            endpoint.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (endpoint.notes != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              endpoint.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        endpoint.path,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'RobotoMono',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: endpoint.supportsExecution
                          ? () => provider.execute(endpoint)
                          : null,
                      icon: switch (state.status) {
                        EndpointExecutionStatus.loading => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        EndpointExecutionStatus.success => const Icon(
                          Icons.check_circle_outline,
                        ),
                        EndpointExecutionStatus.error => const Icon(
                          Icons.error_outline,
                        ),
                        EndpointExecutionStatus.idle => const Icon(
                          Icons.play_arrow_rounded,
                        ),
                      },
                      label: Text(
                        endpoint.supportsExecution ? 'Run' : 'Docs only',
                      ),
                    ),
                  ],
                ),
                if (endpoint.sampleQuery != null) ...[
                  const SizedBox(height: 12),
                  _PayloadPreview(
                    title: 'Query parameters',
                    lines: endpoint.sampleQuery!.entries
                        .map((entry) => '${entry.key}: ${entry.value}')
                        .toList(),
                  ),
                ],
                if (endpoint.sampleBody != null) ...[
                  const SizedBox(height: 12),
                  _PayloadPreview(
                    title: 'Sample body',
                    lines: endpoint.sampleBody!.entries
                        .map((entry) => '${entry.key}: ${entry.value}')
                        .toList(),
                  ),
                ],
                if (state.status == EndpointExecutionStatus.error) ...[
                  const SizedBox(height: 12),
                  _ResultBanner(
                    color: theme.colorScheme.errorContainer,
                    icon: Icons.warning_amber_rounded,
                    text: state.errorMessage ?? 'Unknown error.',
                    textColor: theme.colorScheme.onErrorContainer,
                  ),
                ] else if (state.hasPayload) ...[
                  const SizedBox(height: 12),
                  _ResultBanner(
                    color: theme.colorScheme.primaryContainer,
                    icon: Icons.data_object,
                    text: state.payload!,
                    textColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.method});

  final TmdbV4HttpMethod method;

  Color _backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (method) {
      TmdbV4HttpMethod.get => scheme.tertiaryContainer,
      TmdbV4HttpMethod.post => scheme.secondaryContainer,
      TmdbV4HttpMethod.delete => scheme.errorContainer,
    };
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (method) {
      TmdbV4HttpMethod.get => scheme.onTertiaryContainer,
      TmdbV4HttpMethod.post => scheme.onSecondaryContainer,
      TmdbV4HttpMethod.delete => scheme.onErrorContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(method.name),
      backgroundColor: _backgroundColor(context),
      labelStyle: TextStyle(
        color: _foregroundColor(context),
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _PayloadPreview extends StatelessWidget {
  const _PayloadPreview({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          ...lines.map(
            (line) => Text(
              line,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.color,
    required this.icon,
    required this.text,
    required this.textColor,
  });

  final Color color;
  final IconData icon;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
