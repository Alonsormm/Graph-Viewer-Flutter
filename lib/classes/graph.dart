//  a class that represents a graph this using a list of nodes and a list of edges
import 'package:graph_viewer/classes/edge.dart';
import 'package:graph_viewer/classes/node.dart';

class Graph {
  List<Node> nodes;
  List<Edge> edges;

  Graph({this.nodes = const [], this.edges = const []});

  // a method to convert the graph to a adjacency list
  Map<String, List<String>> toAdjacencyList() {
    Map<String, List<String>> adjacencyList = {};

    for (Node node in nodes) {
      adjacencyList[node.id] = [];
    }

    for (Edge edge in edges) {
      if (adjacencyList.containsKey(edge.source)) {
        adjacencyList[edge.source]!.add(edge.target);
      } else {
        adjacencyList[edge.source] = [edge.target];
      }
    }

    return adjacencyList;
  }

  // a method to convert an adjacency list to a graph
  factory Graph.fromAdjacencyList(Map<String, List<String>> adjacencyList) {
    List<Node> nodes = [];
    List<Edge> edges = [];

    for (String key in adjacencyList.keys) {
      nodes.add(Node(id: key, label: key));
    }

    for (String key in adjacencyList.keys) {
      for (String target in adjacencyList[key]!) {
        edges.add(Edge(id: '$key-$target', source: key, target: target));
      }
    }

    return Graph(nodes: nodes, edges: edges);
  }
}
