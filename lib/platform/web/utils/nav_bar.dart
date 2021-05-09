import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return VxResponsive(
      fallback: VxBox(
        child: <Widget>[
          Image.asset(
            'assets/images/logo/dark_logo.png',
            height: 50,
          ),
          HStack(
            <Widget>[
              'Download'.text.fontFamily('Inter').make().px12(),
              'About'.text.fontFamily('Inter').make().px12(),
            ],
          ).px8(),
        ].row(alignment: MainAxisAlignment.spaceBetween).px12(),
      ).height(100).width(Size.infinite.width).make(),
      large: VxBox(
        child: <Widget>[
          Image.asset(
            'assets/images/logo/dark_logo.png',
            height: 50,
          ),
          HStack(
            <Widget>[
              'Download'.text.fontFamily('Inter').make().px12(),
              'About'.text.fontFamily('Inter').make().px12(),
            ],
            alignment: MainAxisAlignment.spaceEvenly,
          ).px8(),
        ].row(alignment: MainAxisAlignment.spaceBetween).px12(),
      ).height(100).width(Size.infinite.width).make(),
      xsmall: VxBox(
        child: <Widget>[
          Image.asset(
            'assets/images/logo.png',
            height: 50,
          ),
          'Download'.text.fontFamily('Inter').make().px12(),
        ].row(alignment: MainAxisAlignment.spaceBetween).px12(),
      ).height(100).width(Size.infinite.width).make(),
    );
  }
}
