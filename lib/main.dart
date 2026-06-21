import 'package:flutter/material.dart';
import 'board.dart';

void main() {
  runApp(const MyApp());
}

const backgroundColor = Color(0xFF1c1c1c);
// const backgroundColor = Color(0xFFfcba03);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        backgroundColor: backgroundColor, // Blue 900
        body: const Center(
          child: Board(
            imageIdx: 0,
            puzzleSize: 600,
            difficulty: 6,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );
  }
}
