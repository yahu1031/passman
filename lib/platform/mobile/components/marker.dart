import 'dart:ui';
import 'package:flutter/material.dart';


class Marker extends StatelessWidget {
  const Marker({
    required this.dx,
    required this.dy,
  });
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) => Positioned(
        top: dy - 20,
      left: dx - 20,
      child: CustomPaint(
        size: const Size(50.0, 50.0),
        painter: DotMarker(),
      ),
    );
}

class DotMarker extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, 0);
    path_0.lineTo(size.width, 0);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(0, size.height);
    path_0.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Colors.red.withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5),
        size.width * 0.1666667, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
