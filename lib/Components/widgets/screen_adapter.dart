import 'dart:math';

import 'package:flutter/material.dart';

class ScreenAdapter extends StatelessWidget {
  ScreenAdapter({this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    double preferredWidth = 600.0,
        contentWidth =
        min(MediaQuery.of(context).size.width, preferredWidth);
    return Container(
      child: Center(
        child: Container(
          width: contentWidth,
          child: child,
        ),
      ),
    );
  }
}
