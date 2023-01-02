import 'package:flutter/material.dart';

class NodePosition {
  final String id;
  double x;
  double y;

  NodePosition({required this.id, this.x = 0, this.y = 0});

  Offset get position => Offset(x, y);
}
