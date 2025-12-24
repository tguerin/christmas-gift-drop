import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const ChristmasApp());
}

class ChristmasApp extends StatelessWidget {
  const ChristmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: StockingFillerGame());
  }
}

class Present {
  double x;
  double y;
  String emoji;

  Present({required this.x, required this.y, required this.emoji});
}

class StockingFillerGame extends StatefulWidget {
  const StockingFillerGame({super.key});

  @override
  State<StockingFillerGame> createState() => _StockingFillerGameState();
}

class _StockingFillerGameState extends State<StockingFillerGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final random = Random();

  final presentEmojis = ['🎁', '🎀', '⭐', '🎄'];
  final stockingWidth = 80.0;
  final stockingHeight = 60.0;

  @override
  void initState() {
    super.initState();
    // Your game initialization here
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text('🎁 Stocking Filler - Score: 0'), // TODO: Show actual score
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Container(), // Your game here
    );
  }
}
