import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.initialTab});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Home Page - Initial Tab: $initialTab'),
      ),
    );
  }
}

 