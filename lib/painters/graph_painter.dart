import 'package:flutter/material.dart';
import 'package:graph_viewer/classes/graph.dart';
import 'package:graph_viewer/classes/node_position.dart';

class GraphPainter extends CustomPainter {
  final Graph graph;
  final List<NodePosition> nodePositions;
  final Offset center;
  final double scale;

  GraphPainter({
    required this.graph,
    required this.nodePositions,
    this.center = Offset.zero,
    this.scale = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // the 0,0 point is in the top center of the canvas
    // we need to translate the canvas to the center of the screen
    canvas.translate(size.width / 2, size.height / 2);
    // draw the edges
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2 * scale;

    for (final edge in graph.edges) {
      final source = nodePositions.firstWhere((nodePosition) {
        return nodePosition.id == edge.source;
      });
      final target = nodePositions.firstWhere((nodePosition) {
        return nodePosition.id == edge.target;
      });
      // canvas.drawLine(source.position, target.position, paint);
      // draw the line with the offset
      canvas.drawLine(
        source.position + center,
        target.position + center,
        paint,
      );
    }

    // draw the nodes
    final nodePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    // draw the nodes with the label in the center
    for (final nodePosition in nodePositions) {
      // changing the position based on the center and the scale
      canvas.drawCircle(nodePosition.position + center, 10 * scale, nodePaint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: graph.nodes.firstWhere((node) {
            return node.id == nodePosition.id;
          }).label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12 * scale,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        nodePosition.position +
            center -
            Offset(
                textPainter.width / 2 * scale, textPainter.height / 2 * scale),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as GraphPainter).center != center;
  }
}
