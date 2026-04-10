import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class TianZiGeBackground extends StatelessWidget {
  final Widget child;
  final double gridSize;

  const TianZiGeBackground({
    super.key,
    required this.child,
    this.gridSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.tianzigeBg,
      ),
      child: CustomPaint(
        painter: TianZiGePainter(gridSize: gridSize),
        child: child,
      ),
    );
  }
}

class TianZiGePainter extends CustomPainter {
  final double gridSize;

  TianZiGePainter({this.gridSize = 80});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tianzigeLine.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    final boldPaint = Paint()
      ..color = AppColors.tianzigeLine
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += gridSize * 2) {
      for (double y = 0; y < size.height; y += gridSize * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, gridSize * 2, gridSize * 2),
          boldPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TianZiGePainter oldDelegate) {
    return oldDelegate.gridSize != gridSize;
  }
}