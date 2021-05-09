import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashContent extends StatelessWidget {
  const SplashContent(
    this.title,
    this.asset,
    this.content, {
    Key? key,
  }) : super(key: key);
  final String title, asset, content;
  @override
  Widget build(BuildContext context) {
    return VStack(
      <Widget>[
        title.text.fontFamily('Inter').bold.xl3.make().py32(),
        Image.asset(asset).centered().w(context.screenWidth * 0.75),
        content.text.fontFamily('Inter').center.xl.makeCentered(),
      ],
      alignment: MainAxisAlignment.spaceBetween,
      crossAlignment: CrossAxisAlignment.center,
    );
  }
}
