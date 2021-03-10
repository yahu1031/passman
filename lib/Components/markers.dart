import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:passman/Components/size_config.dart';

class Marker extends StatelessWidget {
  const Marker({this.dx, this.dy});
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: dy - 5 * SizeConfig.widthMultiplier,
      left: dx - 5 * SizeConfig.widthMultiplier,
      child: CustomPaint(
        size: const Size(50.0, 50.0),
        painter: DotMarker(),
      ),
    );
  }
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
