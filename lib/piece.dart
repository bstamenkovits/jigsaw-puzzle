import 'package:flutter/material.dart';

/// Data model for a jigsaw puzzle piece.
class PieceData {
  /// Unique identifier for the piece.
  final String id;
  /// Current position of the piece on the board.
  Offset position;
  /// Piece dimensions
  final double width;
  final double height;

  PieceData({
    required this.id,
    this.position = Offset.zero,
    this.width = 80.0,
    this.height = 120.0,
  });

  /// Anchor points for snapping logic.
  Offset get topAnchor => position + Offset(width / 2, 0);
  Offset get bottomAnchor => position + Offset(width / 2, height);
  Offset get leftAnchor => position + Offset(0, height / 2);
  Offset get rightAnchor => position + Offset(width, height / 2);
}


/// A widget representing a single jigsaw puzzle piece.
class Piece extends StatelessWidget {
  /// The data associated with this piece.
  final PieceData data;

  /// Callback when the piece is dragged.
  final Function(Offset delta) onDrag;

  /// Callback when the drag ends.
  final VoidCallback onDragEnd;

  const Piece({
    super.key,
    required this.data,
    required this.onDrag,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// when user performs a pan input, call the onDrag method
      /// (method defined at class instantiation)
      onPanUpdate: (details) => onDrag(details.delta),
      onPanEnd: (_) => onDragEnd(),

      /// Visual representation of puzzle piece
      child: Container(
        width: data.width,
        height: data.height,
        color: Colors.grey,
        child: Center(
          child: Text(data.id),
        ),
      ),
    );
  }
}
