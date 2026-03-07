import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [

            /// Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A1F44),
                    Color(0xFF1C3F7C),
                    Color(0xFFEAF2FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            /// Floating Circles
            Positioned(
              top: 100 + sin(_controller.value * 2 * pi) * 30,
              left: 40,
              child: buildCircle(120),
            ),

            Positioned(
              bottom: 150 + cos(_controller.value * 2 * pi) * 40,
              right: 60,
              child: buildCircle(160),
            ),

            Positioned(
              top: 250 + sin(_controller.value * 2 * pi) * 20,
              right: 100,
              child: buildCircle(80),
            ),
          ],
        );
      },
    );
  }

  Widget buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}