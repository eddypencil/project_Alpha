import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

class NodeIconWidget extends StatelessWidget {
  final NodeModel nodeModel; // Or a factory/lambda to create the node
  final String label;

  const NodeIconWidget({
    super.key,
    required this.nodeModel,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<NodeModel>(
      data: nodeModel,
      feedback: Material(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          
          width: 50,
          height: 50,
          child: Center(child: Image.asset(nodeModel.image)),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.white,
        ),
        width: 50,
        height: 50,
        child: Center(child: Image.asset(nodeModel.image)),
      ),
      onDragStarted: () {
        if (Scaffold.of(context).isDrawerOpen) {
          Scaffold.of(context).closeDrawer();
        }
      },
    );
  }
}
