import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/tmdb_v4_auth_provider.dart';
import '../../widgets/app_drawer.dart';

class V4LoginScreen extends StatelessWidget {
  const V4LoginScreen({super.key});

  static const routeName = '/auth/tmdb-v4';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<TmdbV4AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('TMDB v4 Login')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect your TMDB account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with your TMDB account to execute v4 endpoints that require '
                    'user approval. We\'ll open TMDB\'s authorization page where you '
                    'can grant access to this demo application.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: auth.isSigningIn || !auth.hasRestoredSession
                ? null
                : auth.openAuthorizationPage,
            icon: auth.isSigningIn
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(
              auth.isSigningIn ? 'Waiting for approval…' : 'Authorize with TMDB',
            ),
          ),
          const SizedBox(height: 12),
          if (auth.isAuthenticated)
            OutlinedButton.icon(
              onPressed: auth.isSigningOut ? null : auth.signOut,
              icon: auth.isSigningOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(auth.isSigningOut ? 'Signing out…' : 'Sign out'),
            ),
          if (auth.hasPendingAuthorization && !auth.isSigningOut) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.hourglass_top,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
              message:
                  'We\'re waiting for TMDB to redirect back. Approve the request in your browser and we\'ll finish the sign-in automatically.',
            ),
          ],
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.error_outline,
              color: theme.colorScheme.errorContainer,
              textColor: theme.colorScheme.onErrorContainer,
              message: auth.errorMessage!,
            ),
          ],
          const SizedBox(height: 24),
          _DetailsSection(auth: auth),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.auth});

  final TmdbV4AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final redirectUri = auth.redirectUri.toString();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How this works',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _StepTile(
              index: 1,
              text:
                  'Tap the authorization button above to open TMDB\'s secure login portal.',
            ),
            _StepTile(
              index: 2,
              text:
                  'Approve access for "AllMovies Mobile" on the TMDB site. TMDB will redirect back to the app once complete.',
            ),
            _StepTile(
              index: 3,
              text:
                  'After approval we exchange the request token for a user access token and securely store it on this device.',
            ),
            const SizedBox(height: 12),
            Text(
              'Redirect URI',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            SelectableText(
              redirectUri,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'RobotoMono',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'If the browser does not redirect automatically, copy this URL and paste it into your address bar after approving the request.',
              style: theme.textTheme.bodySmall,
            ),
            if (auth.isAuthenticated) ...[
              const SizedBox(height: 16),
              Text(
                'Current session',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Access token stored securely. Account ID: ${auth.accountId ?? 'Unknown'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              '$index',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.textColor,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final Color textColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
