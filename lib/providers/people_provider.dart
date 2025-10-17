import 'package:flutter/material.dart';
import '../data/models/person_item.dart';

class PeopleProvider extends ChangeNotifier {
  final List<PersonItem> _people = const [
    PersonItem(
      name: 'Zendaya',
      knownFor: 'Euphoria, Dune',
      biography: 'Emmy-winning actor and producer known for grounded performances and fashion-forward style.',
    ),
    PersonItem(
      name: 'Pedro Pascal',
      knownFor: 'The Last of Us, The Mandalorian',
      biography: 'Chilean-American actor beloved for charismatic roles across TV and film.',
    ),
    PersonItem(
      name: 'Greta Gerwig',
      knownFor: 'Barbie, Lady Bird',
      biography: 'Writer-director celebrated for heartfelt storytelling and sharp, character-driven humor.',
    ),
    PersonItem(
      name: 'Hayao Miyazaki',
      knownFor: 'Spirited Away, The Boy and the Heron',
      biography: 'Legendary animator and Studio Ghibli co-founder whose films inspire generations.',
    ),
    PersonItem(
      name: 'Jonathan Majors',
      knownFor: 'Lovecraft Country, Creed III',
      biography: 'Critically acclaimed actor recognized for intense, layered performances.',
    ),
  ];

  List<PersonItem> get people => List.unmodifiable(_people);
}
