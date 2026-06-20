import 'package:flutter/material.dart';

/// Data model for a jigsaw puzzle piece.
class PieceData {
  /// Unique identifier for the piece.
  final String id;
  /// Current position of the piece on the board.
  Offset position;

  PieceData({required this.id, this.position = Offset.zero});
}


/// A widget representing a single jigsaw puzzle piece.
class Piece extends StatelessWidget {
  /// The data associated with this piece.
  final PieceData data;

  /// Callback when the piece is dragged.
  final Function(Offset delta) onDrag;

  const Piece({super.key, required this.data, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// when user performs a pan input, call the onDrag method
      /// (method defined at class instantiation)
      onPanUpdate: (details) => onDrag(details.delta),

      /// Visual representation of puzzle piece
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey,
        child: Center(
          child: Text(data.id),
        ),
      ),
    );
  }
}
