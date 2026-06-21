import 'package:flutter/material.dart';
import 'puzzle_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1c1c1c);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Choose a Puzzle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 136, // Based on the file list
        itemBuilder: (context, index) {
          final imagePath = 'assets/pictures/image$index.jpg';
          return GestureDetector(
            onTap: () => _showDifficultyDialog(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
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
      builder: (context) {
        return DifficultyDialog(imageIdx: imageIdx);
      },
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Difficulty',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Grid Size: ${_difficulty.toInt()} x ...'),
                Slider(
                  value: _difficulty,
                  min: 2,
                  max: 10,
                  divisions: 8,
                  label: _difficulty.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _difficulty = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('PLAY', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
