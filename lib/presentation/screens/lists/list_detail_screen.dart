import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/user_list.dart';
import '../../../providers/lists_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_image.dart';
import 'widgets/list_editor_sheet.dart';

class ListDetailScreen extends StatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListsProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final list = provider.listById(widget.listId);
        if (list == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.list_alt,
              title: 'List unavailable',
              message:
                  'The list you are trying to open could not be found. It may have been deleted or you no longer have access.',
              actionLabel: 'Go back',
              onActionPressed: () => Navigator.of(context).pop(),
            ),
          );
        }

        final isOwner = list.ownerId == provider.currentUserId;
        final isFollowing = list.followerIds.contains(provider.currentUserId);

        return Scaffold(
          appBar: AppBar(
            title: Text(list.name),
            actions: [
              IconButton(
                tooltip: 'Share list',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _shareList(list),
              ),
              if (!isOwner)
                IconButton(
                  tooltip: isFollowing ? 'Unfollow' : 'Follow',
                  icon: Icon(
                    isFollowing ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () => provider.toggleFollow(list.id),
                ),
              PopupMenuButton<_DetailAction>(
                onSelected: (action) => _handleMenuAction(
                  context,
                  provider,
                  list,
                  action,
                ),
                itemBuilder: (context) => [
                  if (list.allowsEditsBy(provider.currentUserId))
                    const PopupMenuItem<_DetailAction>(
                      value: _DetailAction.edit,
                      child: Text('Edit details'),
                    ),
                  if (isOwner)
                    const PopupMenuItem<_DetailAction>(
                      value: _DetailAction.delete,
                      child: Text('Delete list'),
                    ),
                ],
              ),
            ],
          ),
          body: _ListDetailBody(
            list: list,
            isOwner: isOwner,
            canEdit: list.allowsEditsBy(provider.currentUserId),
            currentUserId: provider.currentUserId,
            onRefresh: () => provider.refreshLists(),
            onSortChanged: (mode) =>
                provider.updateListSortMode(list.id, mode),
            onRemoveItem: (entry) => provider.removeEntry(
              list.id,
              entry.mediaId,
              mediaType: entry.mediaType,
            ),
            onReorder: (oldIndex, newIndex) =>
                provider.reorderEntries(list.id, oldIndex, newIndex),
            onAddComment: list.isPublic || isOwner
                ? (message) =>
                    _submitComment(context, provider, list.id, message)
                : null,
            commentController: _commentController,
            isSubmittingComment: _isSubmittingComment,
            onDeleteComment: (commentId) =>
                provider.deleteComment(list.id, commentId),
          ),
        );
      },
    );
  }

  Future<void> _submitComment(
    BuildContext context,
    ListsProvider provider,
    String listId,
    String message,
  ) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await provider.addComment(listId, trimmed);
      _commentController.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  void _handleMenuAction(
    BuildContext context,
    ListsProvider provider,
    UserList list,
    _DetailAction action,
  ) {
    switch (action) {
      case _DetailAction.edit:
        _openEditorSheet(context, list: list);
        break;
      case _DetailAction.delete:
        _confirmDelete(context, provider, list);
        break;
    }
  }

  void _confirmDelete(
    BuildContext context,
    ListsProvider provider,
    UserList list,
  ) {
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
              final success = await provider.deleteList(list.id);
              if (success && context.mounted) {
                Navigator.pop(context);
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

  void _openEditorSheet(BuildContext context, {required UserList list}) {
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
    final collaborative = list.isCollaborative ? 'Collaborative' : 'Solo curated';

    Share.share(
      'Check out the "${list.name}" list on AllMovies.\n'
      'Visibility: $visibility · $collaborative.$description$summary',
      subject: list.name,
    );
  }
}

class _ListDetailBody extends StatelessWidget {
  const _ListDetailBody({
    required this.list,
    required this.isOwner,
    required this.canEdit,
    required this.currentUserId,
    required this.onRefresh,
    required this.onSortChanged,
    required this.onRemoveItem,
    required this.onReorder,
    required this.commentController,
    required this.isSubmittingComment,
    required this.onDeleteComment,
    this.onAddComment,
  });

  final UserList list;
  final bool isOwner;
  final bool canEdit;
  final String currentUserId;
  final Future<void> Function() onRefresh;
  final ValueChanged<ListSortMode> onSortChanged;
  final ValueChanged<ListEntry> onRemoveItem;
  final void Function(int oldIndex, int newIndex) onReorder;
  final TextEditingController commentController;
  final bool isSubmittingComment;
  final void Function(String message)? onAddComment;
  final ValueChanged<String> onDeleteComment;

  @override
  Widget build(BuildContext context) {
    final header = _ListHeader(
      list: list,
      isOwner: isOwner,
      onSortChanged: onSortChanged,
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverToBoxAdapter(child: header),
          ),
        if (list.items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.movie_creation_outlined,
              title: 'No titles yet',
              message: isOwner
                  ? 'Use the add button on movie and TV detail screens to curate this list.'
                  : 'Nothing has been added to this list yet. Check back soon!',
            ),
          )
        else if (list.sortMode == ListSortMode.manual)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverReorderableList(
              itemBuilder: (context, index) {
                final entry = list.items[index];
                return _ReorderableListEntryTile(
                  key: ValueKey('${entry.mediaType.name}-${entry.mediaId}'),
                  index: index,
                  entry: entry,
                  onRemove: canEdit ? () => onRemoveItem(entry) : null,
                );
              },
              itemCount: list.items.length,
              onReorder: onReorder,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = list.items[index];
                  return _ListEntryTile(
                    entry: entry,
                    showDragHandle: false,
                    onRemove: canEdit ? () => onRemoveItem(entry) : null,
                  );
                },
                childCount: list.items.length,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          sliver: SliverToBoxAdapter(
            child: _CommentsSection(
              list: list,
              currentUserId: currentUserId,
              isOwner: isOwner,
              controller: commentController,
              isSubmitting: isSubmittingComment,
              onSubmit: onAddComment,
              onDelete: onDeleteComment,
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.list,
    required this.isOwner,
    required this.onSortChanged,
  });

  final UserList list;
  final bool isOwner;
  final ValueChanged<ListSortMode> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${list.ownerName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: metadataColor,
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
                        const Chip(
                          avatar: Icon(Icons.group_add, size: 16),
                          label: Text('Collaborative'),
                        ),
                      Chip(
                        avatar: const Icon(Icons.movie_filter_outlined, size: 16),
                        label: Text('${list.itemCount} items'),
                      ),
                      if (list.followerIds.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.favorite_outline, size: 16),
                          label: Text('${list.followerIds.length} followers'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (list.description?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text(
            list.description!,
            style: theme.textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Sort by',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<ListSortMode>(
                value: list.sortMode,
                onChanged: (mode) {
                  if (mode != null) {
                    onSortChanged(mode);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: ListSortMode.values
                    .map(
                      (mode) => DropdownMenuItem<ListSortMode>(
                        value: mode,
                        child: Text(mode.label),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        if (list.sortMode == ListSortMode.manual)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.drag_handle,
                  size: 16,
                  color: metadataColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag and drop items to customize the order.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: metadataColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 32),
      ],
    );
  }
}

class _ReorderableListEntryTile extends StatelessWidget {
  const _ReorderableListEntryTile({
    super.key,
    required this.index,
    required this.entry,
    this.onRemove,
  });

  final int index;
  final ListEntry entry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: _ListEntryTile(
        entry: entry,
        showDragHandle: true,
        onRemove: onRemove,
      ),
    );
  }
}

class _ListEntryTile extends StatelessWidget {
  const _ListEntryTile({
    required this.entry,
    required this.showDragHandle,
    this.onRemove,
  });

  final ListEntry entry;
  final bool showDragHandle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final release = entry.releaseDate != null
        ? DateFormat.yMMMd().format(entry.releaseDate!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _EntryPoster(path: entry.posterPath, type: entry.mediaType),
        title: Text(entry.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (release != null)
              Text('Released $release', style: subtitleStyle),
            if (entry.voteAverage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.star_rate_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text(entry.voteAverage!.toStringAsFixed(1)),
                  ],
                ),
              ),
            if (entry.overview != null && entry.overview!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  entry.overview!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
        trailing: (onRemove != null || showDragHandle)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onRemove != null)
                    IconButton(
                      tooltip: 'Remove from list',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onRemove,
                    ),
                  if (showDragHandle)
                    const Icon(
                      Icons.drag_handle,
                      color: Colors.grey,
                    ),
                ],
              )
            : null,
      ),
    );
  }
}

class _EntryPoster extends StatelessWidget {
  const _EntryPoster({this.path, required this.type});

  final String? path;
  final ListEntryType type;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final placeholder = Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Icon(
        entryMediaIcon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    if (path == null || path!.isEmpty) {
      return placeholder;
    }

    if (path!.startsWith('http')) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          path!,
          width: 60,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: MediaImage(
        path: path,
        type: MediaImageType.poster,
        size: MediaImageSize.w185,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
        errorWidget: placeholder,
      ),
    );
  }

  IconData get entryMediaIcon =>
      type == ListEntryType.tv ? Icons.tv_outlined : Icons.movie_outlined;
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({
    required this.list,
    required this.currentUserId,
    required this.isOwner,
    required this.controller,
    required this.isSubmitting,
    required this.onDelete,
    this.onSubmit,
  });

  final UserList list;
  final String currentUserId;
  final bool isOwner;
  final TextEditingController controller;
  final bool isSubmitting;
  final void Function(String message)? onSubmit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (list.comments.isEmpty)
          Text(
            'No comments yet. Start the conversation below.',
            style: theme.textTheme.bodyMedium,
          )
        else
          ...list.comments.map((comment) {
            final canDelete = isOwner || comment.userId == currentUserId;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(comment.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.message),
                  ],
                ),
                trailing: canDelete
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete comment',
                        onPressed: () => onDelete(comment.id),
                      )
                    : null,
              ),
            );
          }),
        const SizedBox(height: 16),
        if (onSubmit == null)
          Card(
            color: theme.colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments are disabled for private lists you do not own.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          Column(
            children: [
              TextField(
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Add a comment',
                  hintText: 'Share what you think about this collection...',
                  border: OutlineInputBorder(),
                ),
                enabled: !isSubmitting,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () => onSubmit!(controller.text),
                  icon: const Icon(Icons.send),
                  label: isSubmitting
                      ? const Text('Posting...')
                      : const Text('Post comment'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ListPoster extends StatelessWidget {
  const _ListPoster({this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    Widget placeholder() => Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: Icon(
            Icons.movie_creation_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );

    if (posterUrl == null || posterUrl!.isEmpty) {
      return placeholder();
    }

    if (posterUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          posterUrl!,
          width: 120,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: MediaImage(
        path: posterUrl,
        type: MediaImageType.poster,
        size: MediaImageSize.w342,
        width: 120,
        height: 160,
        fit: BoxFit.cover,
        errorWidget: placeholder(),
      ),
    );
  }
}

enum _DetailAction { edit, delete }
