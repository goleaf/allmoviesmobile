import 'package:flutter/material.dart';
import '../data/models/company_item.dart';

class CompaniesProvider extends ChangeNotifier {
  final List<CompanyItem> _companies = const [
    CompanyItem(
      name: 'A24',
      originCountry: 'United States',
      description: 'Independent studio championing distinctive storytelling across film and television.',
    ),
    CompanyItem(
      name: 'Studio Ghibli',
      originCountry: 'Japan',
      description: 'Beloved animation house behind timeless adventures and hand-drawn artistry.',
    ),
    CompanyItem(
      name: 'Marvel Studios',
      originCountry: 'United States',
      description: 'Superhero powerhouse shaping the Marvel Cinematic Universe since 2008.',
    ),
    CompanyItem(
      name: 'Bad Robot Productions',
      originCountry: 'United States',
      description: 'Production company blending mystery-box storytelling with blockbuster spectacle.',
    ),
    CompanyItem(
      name: 'BBC Studios',
      originCountry: 'United Kingdom',
      description: 'Global content studio delivering acclaimed drama, documentaries, and natural history.',
    ),
  ];

  List<CompanyItem> get companies => List.unmodifiable(_companies);
}
