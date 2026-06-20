import 'package:flutter/material.dart';
import 'piece.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final List<PieceData> pieces = [
    PieceData(id: "piece_1", position: const Offset(50, 50)),
    PieceData(id: "piece_2", position: const Offset(200, 50)),
    PieceData(id: "piece_3", position: const Offset(50, 200)),
    PieceData(id: "piece_4", position: const Offset(200, 200)),
  ];

  @override
  Widget build(BuildContext context) {
    /// "camera"
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 2.0,
      boundaryMargin: const EdgeInsets.all(1000),

      /// "canvas"
      child: Container(
        width: 2000,
        height: 2000,
        color: Colors.black,

        /// Puzzle Pieces
        child: Stack(
          children: pieces.map((data) {
            return Positioned(
              /// Position of the piece inside of the "canvas"
              left: data.position.dx,
              top: data.position.dy,

              /// setState method rebuilds the UI
              /// this updates left and top attribute of the Positioned widget
              child: Piece(
                data: data,
                /// callback function that gets executed whenever a "drag" input
                /// is detected
                onDrag: (delta) {
                  setState(() {
                    data.position += delta;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
