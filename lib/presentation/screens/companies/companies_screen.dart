import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/media_section_screen.dart';

class CompaniesScreen extends StatelessWidget {
  static const routeName = AppRoutes.companies;

  const CompaniesScreen({super.key});

  static const List<MediaItem> _companies = [
    MediaItem(title: 'Aurora Studios', subtitle: 'San Francisco, USA', icon: Icons.apartment_outlined),
    MediaItem(title: 'Northwind Entertainment', subtitle: 'Toronto, Canada', icon: Icons.business_outlined),
    MediaItem(title: 'Solaris Films', subtitle: 'Madrid, Spain', icon: Icons.domain_outlined),
    MediaItem(title: 'Echo Harbor Productions', subtitle: 'Sydney, Australia', icon: Icons.apartment),
    MediaItem(title: 'Silver Thread Animation', subtitle: 'Tokyo, Japan', icon: Icons.factory_outlined),
    MediaItem(title: 'Cascade Pictures', subtitle: 'Portland, USA', icon: Icons.location_city_outlined),
    MediaItem(title: 'Radiant Wave Studios', subtitle: 'Cape Town, South Africa', icon: Icons.business),
    MediaItem(title: 'Vanguard Media House', subtitle: 'London, UK', icon: Icons.apartment_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return const MediaSectionScreen(
      title: 'Companies',
      titleIcon: Icons.apartment_outlined,
      items: _companies,
      currentRoute: routeName,
      childAspectRatio: 0.8,
    );
  }
}
