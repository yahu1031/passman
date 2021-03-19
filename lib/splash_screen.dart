import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  void platforms() {
    try {
        Navigator.pushReplacementNamed(context, '/state');
    } catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => platforms(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/lottie/fingerprint.json',
            height: 10 * SizeConfig.imageSizeMultiplier,
          ),
        ),
      );
}
