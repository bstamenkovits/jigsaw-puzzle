import 'package:flutter/material.dart';

/// Data model for a jigsaw puzzle piece.
class PieceData {
  /// Unique identifier for the piece.
  final String id;
  /// Current position of the piece on the board.
  Offset position;

  static const double size = 100.0;

  PieceData({required this.id, this.position = Offset.zero});

  /// Anchor points for snapping logic.
  Offset get topAnchor => position + const Offset(size / 2, 0);
  Offset get bottomAnchor => position + const Offset(size / 2, size);
  Offset get leftAnchor => position + const Offset(0, size / 2);
  Offset get rightAnchor => position + const Offset(size, size / 2);
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
