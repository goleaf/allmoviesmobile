import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/person_item.dart';
import '../../../providers/people_provider.dart';
import '../../widgets/app_drawer.dart';

class PeopleScreen extends StatelessWidget {
  static const routeName = '/people';

  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final people = context.watch<PeopleProvider>().people;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.people),
      ),
      drawer: const AppDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: people.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final person = people[index];
          return _PersonCard(person: person);
        },
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final PersonItem person;

  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                person.name.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.knownFor,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    person.biography,
                    style: Theme.of(context).textTheme.bodyMedium,
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
