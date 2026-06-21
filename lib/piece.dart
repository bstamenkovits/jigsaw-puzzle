import 'package:flutter/material.dart';

/// Data model for a jigsaw puzzle piece.
class PieceData {
  /// Unique identifier for the piece.
  final String id;
  /// Grid coordinates
  final int gridX;
  final int gridY;
  /// Current position of the piece on the board.
  Offset position;
  /// Piece dimensions
  final double width;
  final double height;

  PieceData({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.position = Offset.zero,
    this.width = 80.0,
    this.height = 120.0,
  });

  /// Anchor points for snapping logic.
  Offset get topAnchor => position + Offset(width / 2, 0);
  Offset get bottomAnchor => position + Offset(width / 2, height);
  Offset get leftAnchor => position + Offset(0, height / 2);
  Offset get rightAnchor => position + Offset(width, height / 2);

  /// Checks if two pieces are connected (very close to each other)
  bool isConnectedTo(PieceData other, {double connectionThreshold = 2.0}) {
    return (leftAnchor - other.rightAnchor).distance < connectionThreshold ||
           (rightAnchor - other.leftAnchor).distance < connectionThreshold ||
           (topAnchor - other.bottomAnchor).distance < connectionThreshold ||
           (bottomAnchor - other.topAnchor).distance < connectionThreshold;
  }
}


/// A widget representing a single jigsaw puzzle piece.
class Piece extends StatelessWidget {
  /// The data associated with this piece.
  final PieceData data;

  /// Total dimensions of the puzzle.
  final double puzzleWidth;
  final double puzzleHeight;

  /// The path to the image for the puzzle.
  final String imagePath;

  /// Callback when the piece is dragged.
  final Function(Offset delta) onDrag;

  /// Callback when the drag ends.
  final VoidCallback onDragEnd;

  /// Callback when the piece is double tapped.
  final VoidCallback onDoubleTap;

  const Piece({
    super.key,
    required this.data,
    required this.puzzleWidth,
    required this.puzzleHeight,
    required this.imagePath,
    required this.onDrag,
    required this.onDragEnd,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => onDrag(details.delta),
      onPanEnd: (_) => onDragEnd(),
      onDoubleTap: onDoubleTap,

      /// Visual representation of puzzle piece
      child: Container(
        width: data.width,
        height: data.height,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.white24, width: 0.5),5
        ),
        child: Stack(
          children: [
            Positioned(
              left: -data.gridX * data.width,
              top: -data.gridY * data.height,
              child: Image.asset(
                imagePath,
                width: puzzleWidth,
                height: puzzleHeight,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
