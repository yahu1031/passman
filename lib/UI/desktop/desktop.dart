import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/encryption.dart';
import 'package:passman/services/random.dart';
import 'package:qr_flutter/qr_flutter.dart';


class Desktop extends StatefulWidget {
  const Desktop({Key? key}) : super(key: key);
  @override
  _DesktopState createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> with TickerProviderStateMixin {
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(5.0),
  );
  final Encryption encryption = Encryption();
  late AnimationController _controller;
  late String generatedString, encryptedString;
  bool isPin = false, stringMatched = false;
  late Timer timer;
  void timerFunc() {
    timer = Timer.periodic(const Duration(seconds: 100), (Timer timer) {
      setState(() {
        generatedString = RandomNumberGenerator().randomStringGenerator(6);
        encryptedString = encryption.stringEncryption(generatedString).base64;
      });
    });
  }

  @override
  void initState() {
    generatedString = RandomNumberGenerator().randomStringGenerator(6);
    encryptedString = encryption.stringEncryption(generatedString).base64;
    _controller = AnimationController(vsync: this);
    timerFunc();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      body: Center(
        child: Container(
          height: 35 * SizeConfig.imageSizeMultiplier,
          width: 35 * SizeConfig.imageSizeMultiplier,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(7),
          ),
          child: FittedBox(
            child: QrImage(
              data: encryptedString,
              version: 7,
              size: 35 * SizeConfig.widthMultiplier,
            ),
          ),
        ),
      ),
    );
}
