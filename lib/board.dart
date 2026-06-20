import 'package:flutter/material.dart';
import 'piece.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final List<PieceData> pieces = [
    PieceData(id: "piece_11"),
    PieceData(id: "piece_2"),
    PieceData(id: "piece_3"),
    PieceData(id: "piece_4"),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: pieces.map((data) => Piece(data: data)).toList(),
    );
  }
}
