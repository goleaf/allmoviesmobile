import 'package:flutter/material.dart';

void main() {
  runApp(const AllMoviesApp());
}

class AllMoviesApp extends StatelessWidget {
  const AllMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllMovies',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const _PlaceholderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AllMovies')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
