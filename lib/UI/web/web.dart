import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/size_config.dart';

class Web extends StatefulWidget {
  const Web({Key key}) : super(key: key);
  @override
  _WebState createState() => _WebState();
}

class _WebState extends State<Web> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildText(),
      ),
    );
  }

  Text buildText() {
    return Text(
      Platform.operatingSystem,
      style: TextStyle(
        fontFamily: 'Handwriting',
        fontSize: 10 * SizeConfig.widthMultiplier,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
