import 'package:flutter/material.dart';

class CartoonProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;

  const CartoonProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE0E0E0),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clampedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressColor ?? const Color(0xFFFFD700),
                        (progressColor ?? const Color(0xFFFFD700)).withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}