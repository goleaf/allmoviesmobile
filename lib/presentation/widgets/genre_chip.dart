import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey[200],
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}

class GenreChipList extends StatelessWidget {
  final List<String> genres;
  final Set<String>? selectedGenres;
  final Function(String)? onGenreTap;

  const GenreChipList({
    super.key,
    required this.genres,
    this.selectedGenres,
    this.onGenreTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenres?.contains(genre) ?? false;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GenreChip(
              label: genre,
              isSelected: isSelected,
              onTap: onGenreTap != null ? () => onGenreTap!(genre) : null,
            ),
          );
        },
      ),
    );
  }
}
