// create a singleton class for the graph layouter

import 'dart:math';

import 'package:graph_viewer/classes/graph.dart';
import 'package:graph_viewer/classes/node.dart';
import 'package:graph_viewer/classes/node_position.dart';

class GraphLayouter {
  List<NodePosition> springLayout(Graph graph) {
    final nodes = graph.nodes;
    final edges = graph.edges;

    final nodePositions = <NodePosition>[];

    // Initialize the node positions to random values within a certain range.
    final random = Random();
    for (final node in nodes) {
      nodePositions.add(NodePosition(
        id: node.id,
        x: random.nextDouble() * 200,
        y: random.nextDouble() * 200,
      ));
    }

    // Constants used in the spring layout algorithm.
    const springConstant = 0.2;
    const damping = 0.5;
    const tolerance = 1000;

    // Run the spring layout algorithm until convergence.
    var converged = false;
    while (!converged) {
      converged = true;

      // Calculate the displacement for each node.
      for (final node in nodes) {
        final nodePosition = nodePositions.firstWhere((nodePosition) {
          return nodePosition.id == node.id;
        });

        // Calculate the displacement from the edges.
        var displacementX = 0.0;
        var displacementY = 0.0;
        for (final edge in edges) {
          if (edge.source == node.id) {
            final targetNodePosition = nodePositions.firstWhere((nodePosition) {
              return nodePosition.id == edge.target;
            });
            final springDisplacement = _calculateSpringDisplacement(
                nodePosition, targetNodePosition, springConstant);
            displacementX += springDisplacement.x;
            displacementY += springDisplacement.y;
          } else if (edge.target == node.id) {
            final sourceNodePosition = nodePositions.firstWhere((nodePosition) {
              return nodePosition.id == edge.source;
            });
            final springDisplacement = _calculateSpringDisplacement(
                nodePosition, sourceNodePosition, springConstant);
            displacementX += springDisplacement.x;
            displacementY += springDisplacement.y;
          }
        }

        // Calculate the displacement from the other nodes.
        for (final otherNode in nodes) {
          if (otherNode.id != node.id) {
            final otherNodePosition = nodePositions.firstWhere((nodePosition) {
              return nodePosition.id == otherNode.id;
            });
            final dx = nodePosition.x - otherNodePosition.x;
            final dy = nodePosition.y - otherNodePosition.y;
            final distance = sqrt(dx * dx + dy * dy);
            displacementX += dx / distance;
            displacementY += dy / distance;
          }
        }

        // Update the node position.
        final oldX = nodePosition.x;
        final oldY = nodePosition.y;
        nodePosition.x += displacementX * damping;
        nodePosition.y += displacementY * damping;
        if (converged &&
            (nodePosition.x - oldX).abs() > tolerance &&
            (nodePosition.y - oldY).abs() > tolerance) {
          converged = false;
        }
      }
    }

    return nodePositions;
  }

  List<NodePosition> circularLayout(Graph graph, double radius) {
    final nodes = graph.nodes;

    final nodePositions = <NodePosition>[];

    // Initialize the node positions to random values within a certain range.
    final random = Random();
    for (final node in nodes) {
      nodePositions.add(NodePosition(
        id: node.id,
        x: random.nextDouble() * 100,
        y: random.nextDouble() * 100,
      ));
    }

    // Calculate the displacement for each node.
    final angle = 2 * pi / nodes.length;
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

  List<NodePosition> hierarchicalLayout(Graph graph, double initialYpos) {
    final nodes = graph.nodes;
    final edges = graph.edges;

    final nodePositions = <NodePosition>[];

    // Initialize the node positions to random values within a certain range.
    final random = Random();
    for (final node in nodes) {
      nodePositions.add(NodePosition(
        id: node.id,
        x: random.nextDouble() * 100,
        y: random.nextDouble() * 100,
      ));
    }

    // the x can be - and +, the y can be - and +
    // the root node is the one with no incoming edges
    // the steps to do iteratively:
    // 1. find the root node
    // 2. place the root node in the top middle
    // 3. find the children of the root node
    // 4. place the children of the root node in the next level with y offset, and a separation between each node in x on the same level
    // 5. repeat 3 and 4 until all nodes are placed
    // 6. in each iteration chech if there is a node that already has a position

    // find the root node
    final rootNodes = nodes.where((node) {
      return edges.every((edge) {
        return edge.target != node.id;
      });
    }).toList();

    // place the root node in the top middle
    final rootNode = rootNodes.first;
    final rootNodePosition = nodePositions.firstWhere((nodePosition) {
      return nodePosition.id == rootNode.id;
    });
    rootNodePosition.x = 0;
    rootNodePosition.y = initialYpos;

    // 3,4 and 5 using loop
    var level = 1;
    var nodesToPlace = rootNodes;

    final visitedNodes = <String>{};
    while (nodesToPlace.isNotEmpty) {
      final nextNodesToPlace = <Node>{};
      final levelY = initialYpos + level * 100;
      final levelX = 100 * nodesToPlace.length / 2;
      var levelXOffset = -levelX;
      for (final node in nodesToPlace) {
        final nodePosition = nodePositions.firstWhere((nodePosition) {
          return nodePosition.id == node.id;
        });
        nodePosition.x = levelXOffset;
        nodePosition.y = levelY;
        levelXOffset += 100;
        visitedNodes.add(node.id);
        final children = edges.where((edge) {
          return edge.source == node.id;
        }).map((edge) {
          return nodes.firstWhere((node) {
            return node.id == edge.target;
          });
        }).toList();
        nextNodesToPlace.addAll(children);
      }
      nodesToPlace = nextNodesToPlace.toList();
      level++;
    }
    return nodePositions;
  }

  Point<double> _calculateSpringDisplacement(
      NodePosition source, NodePosition target, double springConstant) {
    final dx = source.x - target.x;
    final dy = source.y - target.y;
    final distance = sqrt(dx * dx + dy * dy);
    final displacementX =
        (dx / distance) * (distance - springConstant) * springConstant;
    final displacementY =
        (dy / distance) * (distance - springConstant) * springConstant;
    return Point(displacementX, displacementY);
  }
}
