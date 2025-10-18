import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/tmdb_v4_endpoint.dart';
import '../../../data/tmdb_v4_repository.dart';
import '../../../providers/tmdb_v4_auth_provider.dart';
import '../../../providers/tmdb_v4_reference_provider.dart';
import '../auth/v4_login_screen.dart';
import '../../widgets/app_drawer.dart';

class TmdbV4ReferenceScreen extends StatelessWidget {
  const TmdbV4ReferenceScreen({super.key});

  static const routeName = '/explorer/v4';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<TmdbV4AuthProvider,
        TmdbV4ReferenceProvider>(
      create: (context) => TmdbV4ReferenceProvider(
        context.read<TmdbV4Repository>(),
        context.read<TmdbV4AuthProvider>(),
      ),
      update: (context, auth, provider) {
        provider ??= TmdbV4ReferenceProvider(
          context.read<TmdbV4Repository>(),
          auth,
        );
        provider.updateAuthProvider(auth);
        return provider;
      },
      child: const _TmdbV4ReferenceView(),
    );
  }
}

class _TmdbV4ReferenceView extends StatelessWidget {
  const _TmdbV4ReferenceView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TmdbV4ReferenceProvider>();
    final auth = context.watch<TmdbV4AuthProvider>();
    final groups = provider.groups;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tmdbV4Reference),
        actions: [
          if (!auth.hasRestoredSession ||
              auth.isSigningIn ||
              auth.isSigningOut)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: auth.isAuthenticated
                  ? 'Sign out of TMDB'
                  : 'Sign in to TMDB',
              onPressed: auth.isAuthenticated
                  ? auth.signOut
                  : () => Navigator.of(context)
                      .pushNamed(V4LoginScreen.routeName),
              icon: Icon(
                auth.isAuthenticated ? Icons.logout : Icons.login,
              ),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _AuthStatusCard(auth: auth),
          ),
          if (auth.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _AuthErrorBanner(message: auth.errorMessage!),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return _EndpointGroupCard(group: group);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthStatusCard extends StatelessWidget {
  const _AuthStatusCard({required this.auth});

  final TmdbV4AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAuthenticated = auth.isAuthenticated;
    final waitingApproval = auth.hasPendingAuthorization && auth.isSigningIn;
    final icon = isAuthenticated
        ? Icons.verified_user
        : waitingApproval
            ? Icons.hourglass_top
            : Icons.lock_outline;
    final backgroundColor = isAuthenticated
        ? colorScheme.primaryContainer
        : colorScheme.surfaceVariant;
    final foregroundColor = isAuthenticated
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    final subtitle = waitingApproval
        ? 'Waiting for TMDB approval...'
        : isAuthenticated
            ? 'Account ID: ${auth.accountId ?? 'Unknown'}'
            : 'Sign in with TMDB to enable user-scoped endpoints.';

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: foregroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAuthenticated
                        ? 'TMDB account connected'
                        : 'TMDB account required',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
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
    final canExecute = provider.canExecute(endpoint);
    final auth = context.watch<TmdbV4AuthProvider>();
    final actionLabel = !endpoint.supportsExecution
        ? 'Docs only'
        : endpoint.requiresUserToken && !auth.isAuthenticated
            ? 'Sign in'
            : 'Run';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canExecute
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
                          if (endpoint.requiresUserToken &&
                              !auth.isAuthenticated) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Requires TMDB account authentication.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
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
                      onPressed: canExecute
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
                        actionLabel,
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
