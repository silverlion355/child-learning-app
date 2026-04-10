import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class EnglishLineBackground extends StatelessWidget {
  final Widget child;
  final double lineHeight;

  const EnglishLineBackground({
    super.key,
    required this.child,
    this.lineHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.englishLineBg,
      ),
      child: CustomPaint(
        painter: EnglishLinePainter(lineHeight: lineHeight),
        child: child,
      ),
    );
  }
}

class EnglishLinePainter extends CustomPainter {
  final double lineHeight;

  EnglishLinePainter({this.lineHeight = 60});

  @override
  void paint(Canvas canvas, Size size) {
    final lineSpacing = lineHeight / 4;
    
    final topLinePaint = Paint()
      ..color = AppColors.englishLine
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final middleLinePaint = Paint()
      ..color = AppColors.englishLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bottomLinePaint = Paint()
      ..color = AppColors.englishLine
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotedPaint = Paint()
      ..color = AppColors.englishLine.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = lineSpacing; y < size.height; y += lineSpacing * 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), topLinePaint);
      canvas.drawLine(Offset(0, y + lineSpacing * 2), Offset(size.width, y + lineSpacing * 2), middleLinePaint);
      canvas.drawLine(Offset(0, y + lineSpacing * 3), Offset(size.width, y + lineSpacing * 3), bottomLinePaint);

      for (double x = 0; x < size.width; x += 20) {
        canvas.drawLine(Offset(x, y + lineSpacing), Offset(x + 10, y + lineSpacing), dotedPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant EnglishLinePainter oldDelegate) {
    return oldDelegate.lineHeight != lineHeight;
  }
}