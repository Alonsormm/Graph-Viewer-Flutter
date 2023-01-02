import 'package:flutter/material.dart';
import 'package:graph_viewer/classes/graph.dart';
import 'package:graph_viewer/classes/node_position.dart';
import 'package:graph_viewer/painters/graph_painter.dart';

class GraphViewer extends StatefulWidget {
  final Graph graph;
  final List<NodePosition> nodePositions;
  const GraphViewer(
      {super.key, required this.graph, required this.nodePositions});

  @override
  State<GraphViewer> createState() => _GraphViewerState();
}

class _GraphViewerState extends State<GraphViewer> {
  Offset center = Offset(0, 0);
  // in this widget we are going to draw the graph using the graph and the node positions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Viewer'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            center += details.delta;
          });
        },
        child: SizedBox.expand(
          child: ClipRRect(
            child: CustomPaint(
              // size: the whole screen
              size: MediaQuery.of(context).size,
              painter: GraphPainter(
                graph: widget.graph,
                nodePositions: widget.nodePositions,
                center: center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
