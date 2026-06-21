import 'package:flutter/material.dart';
import '../core/board.dart';
import '../style.dart';

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
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppStyle.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Board(
          imageIdx: imageIdx,
          puzzleSize: 600,
          difficulty: difficulty,
          backgroundColor: AppStyle.background,
        ),
      ),
    );
  }
}

