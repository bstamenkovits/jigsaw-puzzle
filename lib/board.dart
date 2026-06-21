import 'package:flutter/material.dart';
import 'piece.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  /// Each list inside this list represents a "Cluster" of snapped pieces.
  final List<List<PieceData>> clusters = [
    [PieceData(id: "piece_1", position: const Offset(1000, 1000))],
    [PieceData(id: "piece_2", position: const Offset(1200, 1000))],
    [PieceData(id: "piece_3", position: const Offset(1000, 1150))],
    [PieceData(id: "piece_4", position: const Offset(1200, 1150))],
  ];

  /// Distance within which two pieces/clusters snap together
  static const double snapThreshold = 10.0;

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
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// A method to handle dragging:
  ///   - update the position of the moving cluster
  ///   - redraw moving piece at new position
  void _handleDrag(PieceData draggedPiece, Offset delta) {
    setState(() {
      /// Identify which cluster the draggedPiece belongs to
      final movingCluster = clusters.firstWhere((c) => c.contains(draggedPiece));

      /// Update the position of each piece in the cluster
      for (var piece in movingCluster) {
        piece.position += delta;
      }
    });
  }


  /// A method to handle snapping:
  ///   - change position of moving cluster to snapping anchor
  ///   - absorb moving cluster into stationary cluster
  ///   - redraw pieces to screen with updated position
  void _handleDragEnd(PieceData draggedPiece) {
    setState(() {
      /// Identify which cluster the draggedPiece belongs to
      final movingCluster = clusters.firstWhere((c) => c.contains(draggedPiece));

      /// Apply snapping logic
      _handleSnapping(movingCluster);
    });
  }


  /// Given the moving cluster being dragged, try to snap it to another cluster
  void _handleSnapping(List<PieceData> movingCluster) {
    /// Loop over all clusters
    for (var otherCluster in List.from(clusters)) {
      if (otherCluster == movingCluster) continue; // skip check with self

      /// Compare every piece from the moving cluster with the other cluster
      for (var movingPiece in movingCluster) {
        for (var otherPiece in otherCluster) {
          /// Stop after snapping has occurred
          if (_trySnap(movingPiece, otherPiece, movingCluster, otherCluster)) {
            return;
          }
        }
      }
    }
  }

  /// Given two pieces try to snap their corresponding clusters to each other
  bool _trySnap(PieceData a, PieceData b, List<PieceData> clusterA, List<PieceData> clusterB) {
    // A-Left to B-Right
    if (_snapOperation(
        a.leftAnchor, b.rightAnchor,
        clusterA, clusterB,
        b.position + Offset(b.width, 0) - a.position)
    ) { return true; }

    // A-Right to B-Left
    if (_snapOperation(
        a.rightAnchor, b.leftAnchor,
        clusterA, clusterB,
        b.position - Offset(a.width, 0) - a.position)
    ) { return true; }

    // A-Top to B-Bottom
    if (_snapOperation(
        a.topAnchor, b.bottomAnchor,
        clusterA, clusterB,
        b.position + Offset(0, b.height) - a.position)
    ) { return true; }

    // A-Bottom to B-Top
    if (_snapOperation(
        a.bottomAnchor, b.topAnchor,
        clusterA, clusterB,
        b.position - Offset(0, a.height) - a.position)
    ) { return true; }

    return false;
  }

  /// Given two anchors belonging to different clusters (A and B), snap the two
  /// clusters together if the anchors are close enough to one-another.
  bool _snapOperation(Offset anchorA, Offset anchorB, List<PieceData> clusterA, List<PieceData> clusterB, Offset delta) {
    /// Check if two edges are (almost) touching
    if ((anchorA - anchorB).distance < snapThreshold) {

      /// Update the position of all pieces in Cluster A
      for (var piece in clusterA) {
        piece.position += delta;
      }

      /// Absorb clusterA into ClusterB
      clusterB.addAll(clusterA);
      clusters.remove(clusterA);
      return true;
    }
    return false;
  }
}
