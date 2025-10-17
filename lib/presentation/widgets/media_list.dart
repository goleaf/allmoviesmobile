import 'package:flutter/material.dart';

class MediaList extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  const MediaList({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        if (isLoading)
          const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          const SizedBox(
            height: 200,
            child: Center(
              child: Text('No items available'),
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: items[index],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

