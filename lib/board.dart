import 'package:flutter/material.dart';
import 'piece.dart';
import 'puzzle_engine.dart';

class Board extends StatefulWidget {
  final int nPiecesWidth;
  final int nPiecesHeight;
  const Board({
    super.key,
    this.nPiecesWidth = 2,
    this.nPiecesHeight = 2,
  });

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  /// Each list inside this list represents a "Cluster" of snapped pieces.
  late final List<List<PieceData>> clusters;

  @override
  void initState() {
    super.initState();
    clusters = [];
    for (int i = 0; i < widget.nPiecesHeight; i++) {
      for (int j = 0; j < widget.nPiecesWidth; j++) {
        clusters.add([
          PieceData(
            id: "piece_${i * widget.nPiecesWidth + j + 1}",
            gridX: j,
            gridY: i,
            position: Offset(1000.0 + j * 200.0, 1000.0 + i * 150.0),
          )
        ]);
      }
    }
  }

  /// Needed for "infinite canvas"
  final TransformationController _transformationController = TransformationController();

  /// We track the previous minX and minY to adjust the transformation controller
  /// when the canvas origin shifts, preventing the view from "jumping".
  double _lastMinX = 0;
  double _lastMinY = 0;
  bool _hasInitializedBounds = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPieces = clusters.expand((c) => c).toList();

    // 1. Calculate the bounding box of all pieces
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    if (allPieces.isEmpty) {
      minX = 0; minY = 0; maxX = 0; maxY = 0;
    } else {
      for (var p in allPieces) {
        if (p.position.dx < minX) minX = p.position.dx;
        if (p.position.dy < minY) minY = p.position.dy;
        if (p.position.dx + p.width > maxX) maxX = p.position.dx + p.width;
        if (p.position.dy + p.height > maxY) maxY = p.position.dy + p.height;
      }
    }

    // 2. Define a large buffer so pieces are never at the absolute edge of the Stack
    const double buffer = 2000.0;
    final canvasWidth = (maxX - minX) + 2 * buffer;
    final canvasHeight = (maxY - minY) + 2 * buffer;

    // 3. Adjust TransformationController to compensate for coordinate shift
    if (!_hasInitializedBounds) {
      _lastMinX = minX;
      _lastMinY = minY;
      _hasInitializedBounds = true;
      // Initial centering (optional, depends on initial piece positions)
      _transformationController.value = Matrix4.translationValues(-buffer, -buffer, 0);
    } else {
      final double dx = minX - _lastMinX;
      final double dy = minY - _lastMinY;
      if (dx != 0 || dy != 0) {
        // Shift the transformation to compensate for the origin shift in the Stack.
        // We use Matrix4.copy to ensure the ValueNotifier detects a change.
        final Matrix4 current = _transformationController.value;
        _transformationController.value = Matrix4.copy(current)..translateByDouble(dx, dy, 0.0, 1.0);
        _lastMinX = minX;
        _lastMinY = minY;
      }
    }

    return Container(
      color: Colors.blue[900], // Matches Scaffold background
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        constrained: false, // Allows the child to be larger than the viewport
        child: Container(
          width: canvasWidth,
          height: canvasHeight,
          color: Colors.blue[900], // Matches everything else
          child: Stack(
            clipBehavior: Clip.none,
            children: allPieces.map((data) {
              return Positioned(
                // Translate world coordinates to local Stack coordinates
                left: data.position.dx - minX + buffer,
                top: data.position.dy - minY + buffer,
                child: Piece(
                  data: data,
                  onDrag: (delta) => _handleDrag(data, delta),
                  onDragEnd: () => _handleDragEnd(data),
                  onDoubleTap: () => _handleDoubleTap(data),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap(PieceData piece) {
    setState(() {
      final oldCluster = clusters.firstWhere((c) => c.contains(piece));
      oldCluster.remove(piece);

      // Move the separated piece away slightly (20px) to prevent immediate re-snap
      piece.position += const Offset(20, 20);
      clusters.add([piece]);

      if (oldCluster.isEmpty) {
        clusters.remove(oldCluster);
      } else {
        final newSubClusters = PuzzleEngine.generateNewClusters(oldCluster);
        clusters.remove(oldCluster);
        clusters.addAll(newSubClusters);
      }
    });
  }

  void _handleDrag(PieceData draggedPiece, Offset delta) {
    setState(() {
      final movingCluster = clusters.firstWhere((c) => c.contains(draggedPiece));
      for (var piece in movingCluster) {
        piece.position += delta;
      }
    });
  }

  void _handleDragEnd(PieceData draggedPiece) {
    setState(() {
      final movingCluster = clusters.firstWhere((c) => c.contains(draggedPiece));

      PuzzleEngine.handleSnapping(movingCluster, clusters);

      if (PuzzleEngine.isPuzzleComplete(movingCluster, widget.nPiecesWidth, widget.nPiecesHeight)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Puzzle Complete!")),
        );
      }
    });
  }
}
