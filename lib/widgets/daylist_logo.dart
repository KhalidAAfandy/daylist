import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A sunrise and check mark: a fresh day, one task at a time.
class DaylistLogo extends StatelessWidget {
  const DaylistLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Daylist logo',
    image: true,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD43B),
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: CustomPaint(painter: _DaylistMark()),
    ),
  );
}

class _DaylistMark extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()
      ..color = const Color(0xFF292719)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawArc(
      const Rect.fromLTWH(29, 29, 42, 42),
      0,
      math.pi * 2,
      false,
      paint,
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(50 + 30 * math.cos(angle), 50 + 30 * math.sin(angle)),
        Offset(50 + 36 * math.cos(angle), 50 + 36 * math.sin(angle)),
        paint,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(40, 50)
        ..lineTo(47, 57)
        ..lineTo(61, 43),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
