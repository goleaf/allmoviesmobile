import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/media_image_helper.dart';
import '../../../data/models/user_list.dart';
import '../../../providers/lists_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_image.dart';
import 'list_detail_screen.dart';
import 'widgets/list_editor_sheet.dart';

class ListsScreen extends StatelessWidget {
  static const String routeName = '/lists';

  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditorSheet(context),
        tooltip: 'Create a new list',
        child: const Icon(Icons.add),
      ),
      body: Consumer<ListsProvider>(
        builder: (context, provider, _) {
          if (!provider.isInitialized || provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.lists.isEmpty) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: () => provider.refreshLists(),
            );
          }

          final myLists = provider.myLists;
          final following = provider.followingLists;
          final discoverable = provider.discoverableLists;
          final hasAny =
              myLists.isNotEmpty || following.isNotEmpty || discoverable.isNotEmpty;

          if (!hasAny) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.featured_play_list_outlined,
                title: 'Create your first list',
                message:
                    'Curate your favourite movies and shows into themed collections. Tap the + button to get started.',
                actionLabel: 'Create list',
                onActionPressed: () => _openEditorSheet(context),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              const _SectionHeader(label: 'My lists'),
              if (myLists.isNotEmpty)
                ...myLists.map(
                  (list) => _ListCard(
                    list: list,
                    isOwner: true,
                    onEdit: () => _openEditorSheet(context, list: list),
                  ),
                ),
              const SizedBox(height: 24),
              const _SectionHeader(label: 'Following'),
              if (following.isNotEmpty)
                ...following.map(
                  (list) => _ListCard(
                    list: list,
                    isOwner: false,
                    onEdit: null,
                  ),
                ),
              if (following.isNotEmpty) const SizedBox(height: 24),
              const _SectionHeader(label: 'Popular lists'),
              if (discoverable.isNotEmpty)
                ...discoverable.map(
                  (list) => _ListCard(
                    list: list,
                    isOwner: list.ownerId == provider.currentUserId,
                    onEdit: list.ownerId == provider.currentUserId
                        ? () => _openEditorSheet(context, list: list)
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openEditorSheet(BuildContext context, {UserList? list}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ListEditorSheet(initialList: list),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.list, required this.isOwner, this.onEdit});

  final UserList list;
  final bool isOwner;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ListsProvider>();
    final canEdit = list.allowsEditsBy(provider.currentUserId);
    final followerCount = list.followerIds.length;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ListDetailScreen(listId: list.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ListPoster(posterUrl: list.posterPath),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${list.ownerName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (list.description != null &&
                        list.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          list.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(
                            list.isPublic ? Icons.public : Icons.lock,
                            size: 16,
                          ),
                          label: Text(list.isPublic ? 'Public' : 'Private'),
                        ),
                        if (list.isCollaborative)
                          Chip(
                            avatar: const Icon(Icons.group_add, size: 16),
                            label: const Text('Collaborative'),
                          ),
                        Chip(
                          avatar: const Icon(Icons.movie_outlined, size: 16),
                          label: Text('${list.itemCount} items'),
                        ),
                        if (followerCount > 0)
                          Chip(
                            avatar: const Icon(
                              Icons.favorite_outline,
                              size: 16,
                            ),
                            label: Text('$followerCount followers'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _shareList(list),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                        const SizedBox(width: 8),
                        if (!isOwner)
                          TextButton.icon(
                            onPressed: () => provider.toggleFollow(list.id),
                            icon: Icon(
                              list.followerIds.contains(provider.currentUserId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              list.followerIds.contains(provider.currentUserId)
                                  ? 'Unfollow'
                                  : 'Follow',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ListMenuAction>(
                onSelected: (action) =>
                    _handleMenuAction(context, provider, action),
                itemBuilder: (context) => [
                  if (isOwner && onEdit != null)
                    const PopupMenuItem<_ListMenuAction>(
                      value: _ListMenuAction.edit,
                      child: Text('Edit details'),
                    ),
                  const PopupMenuItem<_ListMenuAction>(
                    value: _ListMenuAction.share,
                    child: Text('Share'),
                  ),
                  if (!isOwner)
                    PopupMenuItem<_ListMenuAction>(
                      value: _ListMenuAction.follow,
                      child: Text(
                        list.followerIds.contains(provider.currentUserId)
                            ? 'Unfollow'
                            : 'Follow',
                      ),
                    ),
                  if (isOwner)
                    const PopupMenuItem<_ListMenuAction>(
                      value: _ListMenuAction.delete,
                      child: Text('Delete'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    ListsProvider provider,
    _ListMenuAction action,
  ) {
    switch (action) {
      case _ListMenuAction.edit:
        if (onEdit != null) {
          onEdit!();
        }
        break;
      case _ListMenuAction.share:
        _shareList(list);
        break;
      case _ListMenuAction.follow:
        provider.toggleFollow(list.id);
        break;
      case _ListMenuAction.delete:
        _confirmDelete(context, provider);
        break;
    }
  }

  void _confirmDelete(BuildContext context, ListsProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete list'),
        content: Text(
          'Are you sure you want to delete "${list.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteList(list.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${list.name}"')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareList(UserList list) {
    final description = list.description?.isNotEmpty == true
        ? '\n\n${list.description!.trim()}'
        : '';
    final topItems = list.items
        .take(5)
        .map((item) => '• ${item.title}')
        .join('\n');
    final summary = topItems.isEmpty ? '' : '\n\nTop picks:\n$topItems';

    final visibility = list.isPublic ? 'Public' : 'Private';
    final collaborative = list.isCollaborative
        ? 'Collaborative'
        : 'Solo curated';

    Share.share(
      'Check out the "${list.name}" list on AllMovies.\n'
      'Visibility: $visibility · $collaborative.$description$summary',
      subject: list.name,
    );
  }
}

class _ListPoster extends StatelessWidget {
  const _ListPoster({this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    final isFullUrl = posterUrl != null && posterUrl!.startsWith('http');

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: 80,
        height: 120,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: () {
          if (posterUrl == null || posterUrl!.isEmpty) {
            return const _PosterFallback();
          }
          if (isFullUrl) {
            return Image.network(
              posterUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => const _PosterFallback(),
            );
          }
          return MediaImage(
            path: posterUrl,
            type: MediaImageType.poster,
            size: MediaImageSize.w342,
            fit: BoxFit.cover,
            errorWidget: const _PosterFallback(),
          );
        }(),
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.movie_filter_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum _ListMenuAction { edit, share, follow, delete }

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load lists',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
