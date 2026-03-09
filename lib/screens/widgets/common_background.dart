import 'package:flutter/material.dart';

class CommonBackground extends StatelessWidget {

  final Widget child;

  const CommonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color(0xFFF5F5F5),
      child: child,
    );

  }
}