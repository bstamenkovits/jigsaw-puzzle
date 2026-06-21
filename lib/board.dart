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
    [PieceData(id: "piece_1", position: const Offset(50, 50))],
    [PieceData(id: "piece_2", position: const Offset(200, 50))],
    [PieceData(id: "piece_3", position: const Offset(50, 200))],
    [PieceData(id: "piece_4", position: const Offset(200, 200))],
  ];

  /// Distance within which two pieces/clusters snap together
  static const double snapThreshold = 10.0;

  @override
  Widget build(BuildContext context) {
    final allPieces = clusters.expand((c) => c).toList();

    return Container(
      color: Colors.blue[900], // Board widget background
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 2.0,
        boundaryMargin: const EdgeInsets.all(1000),
        child: Container(
          width: 2000,
          height: 2000,
          color: Colors.green[900], // Canvas/Stack background
          child: Stack(
            children: allPieces.map((data) {
              return Positioned(
                left: data.position.dx,
                top: data.position.dy,
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
    /// Redraw entire UI after code below gets executed
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
    /// Redraw UI after code below gets executed
    setState(() {
      /// Identify which cluster the draggedPiece belongs to
      final movingCluster = clusters.firstWhere((c) => c.contains(draggedPiece));

      /// Apply snapping logic
      _handleSnapping(movingCluster);
    });
  }


  /// Given the moving cluster being dragged, try to snap it to another cluster
  ///
  /// Each piece from one cluster is compared to each piece from the "other" cluster.
  /// the _trySnap method will check if the relevant anchors of the moving cluster
  /// piece is close enough to the "other" cluster piece. If this is the case the
  /// moving cluster is snapped to the anchor of the "other" cluster, and the moving
  /// cluster is absorbed into the "other" cluster.
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
  /// using the _snapOperation method based on the relevant anchors.
  ///
  /// If a snap occurs, Cluster A's position will snap to Cluster B's position.
  /// All of the pieces in Cluster A are then added to Cluster B, and Cluster A
  /// will be destroyed.
  ///
  /// Only complementary anchors are considered (i.e. only anchors which are
  /// snappable are compared)
  ///
  /// Returns true if a snapping operation occurred between the two clusters,
  /// false otherwise.
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
  ///
  /// Returns true if a snapping operation occurred between the two clusters,
  /// false otherwise.
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
