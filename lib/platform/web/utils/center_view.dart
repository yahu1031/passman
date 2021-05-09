import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CenteredView extends StatelessWidget {
  const CenteredView({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size.height / 40,
        horizontal: size.width / 30,
      ),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width,
        ),
        child: child,
      ),
    );
  }
}
