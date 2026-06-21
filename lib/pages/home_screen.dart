import 'package:flutter/material.dart';
import 'puzzle_page.dart';
import '../style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        title: const Text('Jigsaw Puzzles', style: AppStyle.heading),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppStyle.paddingMedium,
          mainAxisSpacing: AppStyle.paddingMedium,
        ),
        itemCount: 136,
        itemBuilder: (context, index) {
          final imagePath = 'assets/pictures/image$index.jpg';
          return GestureDetector(
            onTap: () => _showDifficultyDialog(context, index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppStyle.borderRadius / 2),
                border: Border.all(color: AppStyle.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppStyle.borderRadius / 2 - 1),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, int imageIdx) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => DifficultyDialog(imageIdx: imageIdx),
    );
  }
}

class DifficultyDialog extends StatefulWidget {
  final int imageIdx;
  const DifficultyDialog({super.key, required this.imageIdx});

  @override
  State<DifficultyDialog> createState() => _DifficultyDialogState();
}

class _DifficultyDialogState extends State<DifficultyDialog> {
  double _difficulty = 3;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: AppStyle.cardDecoration,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppStyle.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Difficulty', style: AppStyle.heading),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pieces:', style: AppStyle.body),
                        Text(
                          '${_difficulty.toInt()} x ...',
                          style: AppStyle.body.copyWith(
                            color: AppStyle.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppStyle.accent,
                        inactiveTrackColor: AppStyle.border,
                        thumbColor: AppStyle.accent,
                        overlayColor: AppStyle.accent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _difficulty,
                        min: 2,
                        max: 10,
                        divisions: 8,
                        onChanged: (value) => setState(() => _difficulty = value),
                      ),
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PuzzlePage(
                              imageIdx: widget.imageIdx,
                              difficulty: _difficulty.toInt(),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppStyle.accent,
                          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                        ),
                        child: const Text('PLAY', style: AppStyle.buttonLabel),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppStyle.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

