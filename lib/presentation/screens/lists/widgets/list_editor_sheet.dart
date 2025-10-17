import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/user_list.dart';
import '../../../../providers/lists_provider.dart';

class ListEditorSheet extends StatefulWidget {
  const ListEditorSheet({super.key, this.initialList});

  final UserList? initialList;

  @override
  State<ListEditorSheet> createState() => _ListEditorSheetState();
}

class _ListEditorSheetState extends State<ListEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _posterController;
  bool _isPublic = true;
  bool _isCollaborative = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialList;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    _posterController = TextEditingController(text: initial?.posterPath ?? '');
    _isPublic = initial?.isPublic ?? true;
    _isCollaborative = initial?.isCollaborative ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialList != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit list' : 'Create a new list',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Cozy Sunday picks',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                if (value.trim().length < 3) {
                  return 'Use at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What makes this list special?',
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _posterController,
              decoration: const InputDecoration(
                labelText: 'Poster URL',
                hintText: 'Optional image for your list',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _isPublic,
              contentPadding: EdgeInsets.zero,
              title: const Text('Public list'),
              subtitle: const Text('Visible to everyone and shareable'),
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            SwitchListTile.adaptive(
              value: _isCollaborative,
              contentPadding: EdgeInsets.zero,
              title: const Text('Collaborative'),
              subtitle:
                  const Text('Allow collaborators to add and reorder items'),
              onChanged: (value) => setState(() => _isCollaborative = value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSubmitting ? null : () => _submit(context),
                  child: Text(isEditing ? 'Save changes' : 'Create list'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ListsProvider>();
    setState(() {
      _isSubmitting = true;
    });

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final poster = _posterController.text.trim();

    try {
      if (widget.initialList == null) {
        final list = await provider.createList(
          name: name,
          description: description.isEmpty ? null : description,
          isPublic: _isPublic,
          isCollaborative: _isCollaborative,
          posterPath: poster.isEmpty ? null : poster,
        );

        if (list != null && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Created "${list.name}"')),
          );
        }
      } else {
        await provider.updateListMetadata(
          widget.initialList!.id,
          name: name,
          description: description,
          isPublic: _isPublic,
          isCollaborative: _isCollaborative,
          posterPath: poster,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated "${widget.initialList!.name}"')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
