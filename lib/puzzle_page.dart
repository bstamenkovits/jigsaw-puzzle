import 'package:flutter/material.dart';
import 'board.dart';

class PuzzlePage extends StatelessWidget {
  final int imageIdx;
  final int difficulty;

  const PuzzlePage({
    super.key,
    required this.imageIdx,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1c1c1c);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Board(
          imageIdx: imageIdx,
          puzzleSize: 600,
          difficulty: difficulty,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
