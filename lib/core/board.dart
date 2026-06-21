import 'dart:math';

import 'package:flutter/material.dart';
import 'piece.dart';
import './puzzle_engine.dart';
import '../style.dart';

class Board extends StatefulWidget {
  final int imageIdx;
  final int puzzleSize;
  final int difficulty;
  final Color backgroundColor;

  const Board({
    super.key,
    this.imageIdx = 0,
    this.puzzleSize = 600,
    this.difficulty = 3,
    this.backgroundColor = AppStyle.background,
  });

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  /// Each list inside this list represents a "Cluster" of snapped pieces.
  List<List<PieceData>>? clusters;
  String? _imagePath;
  double? _puzzleWidth;
  double? _puzzleHeight;
  int? _nPiecesWidth;
  int? _nPiecesHeight;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  void _initializePuzzle() {
    final imagePath = 'assets/pictures/image${widget.imageIdx}.jpg';
    _imagePath = imagePath;

    final ImageStream stream = AssetImage(imagePath).resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;

      final int width = info.image.width;
      final int height = info.image.height;
      final double aspectRatio = height / width;

      final puzzleWidth = widget.puzzleSize.toDouble();
      final puzzleHeight = widget.puzzleSize * aspectRatio;

      final nPiecesWidth = widget.difficulty;
      final nPiecesHeight = (widget.difficulty * aspectRatio).round();

      final pieceWidth = puzzleWidth / nPiecesWidth;
      final pieceHeight = puzzleHeight / nPiecesHeight;

      final List<List<PieceData>> newClusters = [];
      final List<Offset> placedPositions = [];

      final random = Random();
      final x0 = 1000.0;
      final y0 = 1000.0;
      final num minDistance = 2 * pow(pow(max(pieceWidth, pieceHeight), 2), 0.5) * 1.1; //estimate for overlapping distance

      for (int i = 0; i < nPiecesHeight; i++) {
        for (int j = 0; j < nPiecesWidth; j++) {
          bool tooClose = true;
          Offset randomPos = Offset(x0, y0); // assign default value

          for (int c=0; c<500; c++){
            // assign a random position
            double x = x0 + 2.5 * puzzleWidth * random.nextDouble();
            double y = y0 + 2.5 * puzzleHeight * random.nextDouble();
            randomPos = Offset(x, y);

            // check if random position is not too close to other pieces
            // if it is, nudge it away from the already placed position
            tooClose = false;
            for (final otherPos in placedPositions) {
              Offset separation = randomPos - otherPos;
              if (separation.distance < minDistance) {
                randomPos += separation * 0.25; // nudge along separation axis
                tooClose = true;
                break;
              }
            }

            // if the new position is far away enough from all other pieces
            // we can use that position
            if (!tooClose) { break; }
          }

          newClusters.add([
            PieceData(
              id: "piece_${i * nPiecesWidth + j + 1}",
              gridX: j,
              gridY: i,
              width: pieceWidth,
              height: pieceHeight,
              position: randomPos,
            )
          ]);

          placedPositions.add(randomPos);
        }
      }

      setState(() {
        _puzzleWidth = puzzleWidth;
        _puzzleHeight = puzzleHeight;
        _nPiecesWidth = nPiecesWidth;
        _nPiecesHeight = nPiecesHeight;
        clusters = newClusters;
      });
    }));
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
    if (clusters == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final allPieces = clusters!.expand((c) => c).toList();

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

    return Stack(
      children: [
        Container(
          color: widget.backgroundColor,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            constrained: false, // Allows the child to be larger than the viewport
            child: Container(
              width: canvasWidth,
              height: canvasHeight,
              color: widget.backgroundColor,
              child: Stack(
                clipBehavior: Clip.none,
                children: allPieces.map((data) {
                  return Positioned(
                    // Translate world coordinates to local Stack coordinates
                    left: data.position.dx - minX + buffer,
                    top: data.position.dy - minY + buffer,
                    child: Piece(
                      data: data,
                      puzzleWidth: _puzzleWidth!,
                      puzzleHeight: _puzzleHeight!,
                      imagePath: _imagePath!,
                      onDrag: (delta) => _handleDrag(data, delta),
                      onDragEnd: () => _handleDragEnd(data),
                      onDoubleTap: () => _handleDoubleTap(data),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (_isComplete)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.paddingLarge,
                  vertical: AppStyle.paddingMedium,
                ),
                decoration: AppStyle.cardDecoration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppStyle.success, size: 28),
                    const SizedBox(width: 16),
                    const Text("Puzzle Complete!", style: AppStyle.heading),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppStyle.accent,
                          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                        ),
                        child: const Text("HOME", style: AppStyle.buttonLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleDoubleTap(PieceData piece) {
    setState(() {
      final oldCluster = clusters!.firstWhere((c) => c.contains(piece));
      oldCluster.remove(piece);

      // Move the separated piece away slightly (20px) to prevent immediate re-snap
      piece.position += const Offset(20, 20);
      clusters!.add([piece]);

      if (oldCluster.isEmpty) {
        clusters!.remove(oldCluster);
      } else {
        final newSubClusters = PuzzleEngine.generateNewClusters(oldCluster);
        clusters!.remove(oldCluster);
        clusters!.addAll(newSubClusters);
      }
    });
  }

  void _handleDrag(PieceData draggedPiece, Offset delta) {
    setState(() {
      final movingCluster = clusters!.firstWhere((c) => c.contains(draggedPiece));
      for (var piece in movingCluster) {
        piece.position += delta;
      }
    });
  }

  void _handleDragEnd(PieceData draggedPiece) {
    setState(() {
      final movingCluster = clusters!.firstWhere((c) => c.contains(draggedPiece));

      PuzzleEngine.handleSnapping(movingCluster, clusters!);

      // Re-find the cluster after snapping as it might have been merged
      final updatedCluster = clusters!.firstWhere((c) => c.contains(draggedPiece));

      if (PuzzleEngine.isPuzzleComplete(updatedCluster, _nPiecesWidth!, _nPiecesHeight!)) {
        _isComplete = true;
      }
    });
  }
}
