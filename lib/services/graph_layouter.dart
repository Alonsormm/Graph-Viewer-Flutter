import 'dart:math';

import 'package:graph_viewer/classes/graph.dart';
import 'package:graph_viewer/classes/node.dart';
import 'package:graph_viewer/classes/node_position.dart';

class GraphLayouter {
  List<NodePosition> springLayout(Graph graph,
      {int iterations = 200, double width = 400, double height = 400}) {
    final nodes = graph.nodes;
    final edges = graph.edges;

    final nodePositions = <NodePosition>[];
    final random = Random();
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final x = (random.nextDouble() * width) - (width / 2);
      final y = (random.nextDouble() * height) - (height / 2);
      nodePositions.add(NodePosition(id: node.id, x: x, y: y));
    }

    const k = 0.1;
    const k2 = 0.01;

    const threshold = 200.0;

    const maxDistance = 400.0;

    final forces = List<List<double>>.generate(
        nodes.length, (_) => List<double>.filled(2, 0.0));

    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < nodes.length; j++) {
        final fx = forces[j][0];
        final fy = forces[j][1];
        forces[j][0] = 0.0;
        forces[j][1] = 0.0;
        for (var k = 0; k < nodes.length; k++) {
          if (j == k) continue;

          final dx = nodePositions[k].x - nodePositions[j].x;
          final dy = nodePositions[k].y - nodePositions[j].y;
          final distance = sqrt(dx * dx + dy * dy);

          if (distance < threshold) {
            final f = k2 / distance;
            forces[j][0] += f * dx;
            forces[j][1] += f * dy;
          }
        }
      }

      for (var j = 0; j < edges.length; j++) {
        final edge = edges[j];
        final source = edge.source;
        final indexOfSource = nodePositions.indexWhere((nodePosition) {
          return nodePosition.id == source;
        });
        final sourcePosition = nodePositions.firstWhere((nodePosition) {
          return nodePosition.id == source;
        });
        final target = edge.target;
        final targetPosition = nodePositions.firstWhere((nodePosition) {
          return nodePosition.id == target;
        });

        final dx = targetPosition.x - sourcePosition.x;
        final dy = targetPosition.y - sourcePosition.y;
        final distance = sqrt(dx * dx + dy * dy);

        final f = k * (distance - threshold);
        forces[indexOfSource][0] += f * dx;
        forces[indexOfSource][1] += f * dy;
        forces[indexOfSource][0] -= f * dx;
        forces[indexOfSource][1] -= f * dy;
      }

      for (var j = 0; j < nodes.length; j++) {
        final p = nodePositions[j];
        p.x += forces[j][0];
        p.y += forces[j][1];

        p.x = p.x.clamp(-maxDistance, maxDistance);
        p.y = p.y.clamp(-maxDistance, maxDistance);
      }
    }

    return nodePositions;
  }

  List<NodePosition> circularLayout(Graph graph,
      {double width = 400, double height = 400}) {
    final nodes = graph.nodes;

    final nodePositions = <NodePosition>[];

    final random = Random();
    for (final node in nodes) {
      nodePositions.add(NodePosition(
        id: node.id,
        x: random.nextDouble() * 100,
        y: random.nextDouble() * 100,
      ));
    }

    final angle = 2 * pi / nodes.length;
    final radius = min(width, height) / 2;
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final nodePosition = nodePositions.firstWhere((nodePosition) {
        return nodePosition.id == node.id;
      });
      nodePosition.x = radius * cos(i * angle);
      nodePosition.y = radius * sin(i * angle);
    }

    return nodePositions;
  }

  List<NodePosition> hierarchicalLayout(Graph graph,
      {double width = 400, double height = 400}) {
    final nodes = graph.nodes;
    final edges = graph.edges;

    final nodePositions = <NodePosition>[];

    final random = Random();
    for (final node in nodes) {
      nodePositions.add(NodePosition(
        id: node.id,
        x: random.nextDouble() * 100,
        y: random.nextDouble() * 100,
      ));
    }

    final rootNodes = nodes.where((node) {
      return edges.every((edge) {
        return edge.target != node.id;
      });
    });

    final rootNodesCount = rootNodes.length;

    int currentLevel = 0;
    Set<Node> nodesToPlace = rootNodes.toSet();
    while (nodesToPlace.isNotEmpty) {
      final nodesToPlaceCount = nodesToPlace.length;
      final xStep = width / (nodesToPlaceCount + 1);
      double x = xStep;
      for (final node in nodesToPlace) {
        final nodePosition = nodePositions.firstWhere((nodePosition) {
          return nodePosition.id == node.id;
        });
        nodePosition.x = x - width / 2;
        nodePosition.y = currentLevel * 100 - height / 2;
        x += xStep;
      }

      final nextNodesToPlace = <Node>{};
      for (final node in nodesToPlace) {
        final connectedNodes = edges.where((edge) {
          return edge.source == node.id;
        }).map((edge) {
          return nodes.firstWhere((node) {
            return node.id == edge.target;
          });
        });
        nextNodesToPlace.addAll(connectedNodes);
      }
      nodesToPlace = nextNodesToPlace;
      currentLevel++;
    }

    return nodePositions;
  }

  List<NodePosition> randomLayout(Graph graph,
      {double width = 100, double height = 100}) {
    final nodes = graph.nodes;

    final nodePositions = <NodePosition>[];

    final random = Random();
    for (final node in nodes) {
      nodePositions.add(NodePosition(
        id: node.id,
        x: random.nextDouble() * width - width / 2,
        y: random.nextDouble() * height - height / 2,
      ));
    }

    return nodePositions;
  }
}
