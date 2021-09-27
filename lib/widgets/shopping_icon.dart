import 'package:flutter/material.dart';

class ShoppingIcon extends StatelessWidget {
  final Widget child;
  final String value;
  final Color color;

  const ShoppingIcon({
    required this.value,
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          bottom: 6,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).canvasColor,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
