import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graph_viewer/classes/edge.dart';
import 'package:graph_viewer/classes/graph.dart';
import 'package:graph_viewer/classes/node.dart';
import 'package:graph_viewer/services/graph_layouter.dart';
import 'package:graph_viewer/widgets/graph_vierwer.dart';

class HomePage extends StatelessWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // create a graph for testing
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                final graph = _buildGraphForTest();
                final springLayout = GraphLayouter().springLayout(graph);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return GraphViewer(
                    graph: graph,
                    nodePositions: springLayout,
                  );
                })));
              },
              child: const Text('Spring Layout'),
            ),
            TextButton(
              onPressed: () {
                final graph = _buildARandomGraphForTest(50);
                final springLayout = GraphLayouter().circularLayout(graph, 200);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return GraphViewer(
                    graph: graph,
                    nodePositions: springLayout,
                  );
                })));
              },
              child: const Text('Circular Layout'),
            ),
            TextButton(
              onPressed: () {
                final graph = _buildATreeGraphForTest(5);
                print(-(MediaQuery.of(context).size.height / 2));
                final springLayout = GraphLayouter().hierarchicalLayout(
                    graph, -(MediaQuery.of(context).size.height / 2));
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return GraphViewer(
                    graph: graph,
                    nodePositions: springLayout,
                  );
                })));
              },
              child: const Text('Hierarchical Layout'),
            ),
          ],
        ),
      ),
    );
  }

  Graph _buildGraphForTest() {
    return Graph(
      nodes: [
        Node(id: '1', label: '1'),
        Node(id: '2', label: '2'),
        Node(id: '3', label: '3'),
        Node(id: '4', label: '4'),
        Node(id: '5', label: '5'),
        Node(id: '6', label: '6'),
        Node(id: '7', label: '7'),
        Node(id: '8', label: '8'),
        Node(id: '9', label: '9'),
        Node(id: '10', label: '10'),
      ],
      edges: [
        Edge(id: '1-2', source: '1', target: '2'),
        Edge(id: '1-3', source: '1', target: '3'),
        Edge(id: '1-4', source: '1', target: '4'),
        Edge(id: '1-5', source: '1', target: '5'),
        Edge(id: '1-6', source: '1', target: '6'),
        Edge(id: '1-7', source: '1', target: '7'),
        Edge(id: '1-8', source: '1', target: '8'),
        Edge(id: '1-9', source: '1', target: '9'),
        Edge(id: '1-10', source: '1', target: '10'),
        Edge(id: '2-3', source: '2', target: '3'),
        Edge(id: '2-4', source: '2', target: '4'),
        Edge(id: '2-5', source: '2', target: '5'),
        Edge(id: '2-6', source: '2', target: '6'),
        Edge(id: '2-7', source: '2', target: '7'),
        Edge(id: '2-8', source: '2', target: '8'),
        Edge(id: '2-9', source: '2', target: '9'),
        Edge(id: '2-10', source: '2', target: '10'),
        Edge(id: '3-4', source: '3', target: '4'),
        Edge(id: '3-5', source: '3', target: '5'),
        Edge(id: '3-6', source: '3', target: '6'),
        Edge(id: '3-7', source: '3', target: '7'),
        Edge(id: '3-8', source: '3', target: '8'),
        Edge(id: '3-9', source: '3', target: '9'),
        Edge(id: '3-10', source: '3', target: '10'),
        Edge(id: '4-5', source: '4', target: '5'),
        Edge(id: '4-6', source: '4', target: '6'),
      ],
    );
  }

  Graph _buildARandomGraphForTest(int numberOfNodes) {
    final nodes = List.generate(numberOfNodes, (index) {
      return Node(id: '$index', label: '$index');
    });
    final edges = <Edge>[];
    for (var i = 0; i < numberOfNodes; i++) {
      for (var j = 0; j < numberOfNodes; j++) {
        if (i != j && Random().nextDouble() > 0.9) {
          edges.add(Edge(
              id: '${nodes[i].id}-${nodes[j].id}',
              source: nodes[i].id,
              target: nodes[j].id));
        }
      }
    }
    return Graph(nodes: nodes, edges: edges);
  }

  Graph _buildATreeGraphForTest(int numberOfLevels) {
    final nodes = <Node>[];
    final edges = <Edge>[];
    final root = Node(id: '0', label: '0');
    nodes.add(root);
    // create the tree, each node has 2 children, each level has 2^level nodes
    // for (var i = 0; i < numberOfLevels; i++) {
    //   final numberOfNodes = pow(2, i);
    //   final indexOffset = nodes.length;
    //   for (var j = 0; j < numberOfNodes; j++) {
    //     final node = Node(id: '${nodes.length}', label: '${nodes.length}');
    //     nodes.add(node);
    //     // to create a tree, each node has 2 children, so the parent of the current node is at index (indexOffset + j) ~/ 2
    //     final parentIndex = (indexOffset + j) ~/ 2;
    //     final parent = nodes[parentIndex];
    //     edges.add(Edge(
    //         id: '${parent.id}-${node.id}', source: parent.id, target: node.id));
    //   }
    // }
    // the code above is wrong because it not take into account the root node, the code below is correct
    for (var i = 0; i < numberOfLevels; i++) {
      final numberOfNodes = pow(2, i);
      final indexOffset = nodes.length;
      for (var j = 0; j < numberOfNodes; j++) {
        final node = Node(id: '${nodes.length}', label: '${nodes.length}');
        nodes.add(node);
        // to create a tree, each node has 2 children, so the parent of the current node is at index (indexOffset + j) ~/ 2
        final parentIndex = (indexOffset + j) ~/ 2;
        final parent = nodes[parentIndex];
        edges.add(Edge(
            id: '${parent.id}-${node.id}', source: parent.id, target: node.id));
      }
    }

    return Graph(nodes: nodes, edges: edges);
  }
}
