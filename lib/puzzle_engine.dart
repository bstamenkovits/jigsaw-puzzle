import 'package:flutter/material.dart';
import 'piece.dart';

class PuzzleEngine {
  static const double snapThreshold = 20.0;

  /// Given the moving cluster being dragged, try to snap it to another cluster
  static void handleSnapping(
    List<PieceData> movingCluster,
    List<List<PieceData>> allClusters,
  ) {
    for (var otherCluster in List.from(allClusters)) {
      if (otherCluster == movingCluster) continue;

      for (var movingPiece in movingCluster) {
        for (var otherPiece in otherCluster) {
          if (_trySnap(movingPiece, otherPiece, movingCluster, otherCluster, allClusters)) {
            return;
          }
        }
      }
    }
  }

  static bool _trySnap(
    PieceData a,
    PieceData b,
    List<PieceData> clusterA,
    List<PieceData> clusterB,
    List<List<PieceData>> allClusters,
  ) {
    // A-Left to B-Right
    if (_snapOperation(a.leftAnchor, b.rightAnchor, clusterA, clusterB, allClusters,
        b.position + Offset(b.width, 0) - a.position)) return true;

    // A-Right to B-Left
    if (_snapOperation(a.rightAnchor, b.leftAnchor, clusterA, clusterB, allClusters,
        b.position - Offset(a.width, 0) - a.position)) return true;

    // A-Top to B-Bottom
    if (_snapOperation(a.topAnchor, b.bottomAnchor, clusterA, clusterB, allClusters,
        b.position + Offset(0, b.height) - a.position)) return true;

    // A-Bottom to B-Top
    if (_snapOperation(a.bottomAnchor, b.topAnchor, clusterA, clusterB, allClusters,
        b.position - Offset(0, a.height) - a.position)) return true;

    return false;
  }

  static bool _snapOperation(
    Offset anchorA,
    Offset anchorB,
    List<PieceData> clusterA,
    List<PieceData> clusterB,
    List<List<PieceData>> allClusters,
    Offset delta,
  ) {
    if ((anchorA - anchorB).distance < snapThreshold) {
      for (var piece in clusterA) {
        piece.position += delta;
      }
      clusterB.addAll(clusterA);
      allClusters.remove(clusterA);
      return true;
    }
    return false;
  }

  static List<List<PieceData>> generateNewClusters(List<PieceData> pieces) {
    List<List<PieceData>> clusters = [];
    Set<PieceData> visited = {};

    for (var p in pieces) {
      if (!visited.contains(p)) {
        clusters.add(_generateCluster(p, pieces, visited));
      }
    }
    return clusters;
  }

  static List<PieceData> _generateCluster(
    PieceData start,
    List<PieceData> allPieces,
    Set<PieceData> visited,
  ) {
    List<PieceData> cluster = [];
    List<PieceData> queue = [start];
    visited.add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      cluster.add(current);

      for (var other in allPieces) {
        if (!visited.contains(other) && current.isConnectedTo(other)) {
          visited.add(other);
          queue.add(other);
        }
      }
    }
    return cluster;
  }

  static bool isPuzzleComplete(
    List<PieceData> cluster,
    int nPiecesWidth,
    int nPiecesHeight,
  ) {
    if (cluster.length != nPiecesWidth * nPiecesHeight) {
      return false;
    }

    final firstPiece = cluster.first;
    final puzzleOrigin = firstPiece.position -
        Offset(firstPiece.gridX * firstPiece.width, firstPiece.gridY * firstPiece.height);

    for (var piece in cluster) {
      final expectedPosition = puzzleOrigin +
          Offset(piece.gridX * piece.width, piece.gridY * piece.height);

      if ((piece.position - expectedPosition).distance > 1.0) {
        return false;
      }
    }

    return true;
  }
}
