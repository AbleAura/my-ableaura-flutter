import 'package:flutter/material.dart';

class UberStyleBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isButton;

  const UberStyleBox({
    Key? key,
    required this.child,
    this.borderRadius = 8,
    this.isButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: isButton ? Theme.of(context).colorScheme.secondary : Colors.grey[900],
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}