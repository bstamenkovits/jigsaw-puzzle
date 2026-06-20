import 'package:flutter/material.dart';

/// Data model for a jigsaw puzzle piece.
class PieceData {

  /// Unique identifier for the piece.
  final String id;

  PieceData({required this.id});
}


/// A widget representing a single jigsaw puzzle piece.
class Piece extends StatelessWidget {
  /// The data associated with this piece.
  final PieceData data;

  const Piece({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(8),
      color: Colors.grey,
      child: Center(
        child: Text(data.id),
      ),
    );
  }
}
