import 'package:flutter/material.dart';

class CommonBackground extends StatelessWidget {
  final Widget child;

  const CommonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned.fill(
          child: Image.asset(
            "assets/images/grocery_bg.jpg", // use .jpg
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.85),
          ),
        ),

        child,
      ],
    );
  }
}
