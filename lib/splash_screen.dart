import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)
        Navigator.pushReplacementNamed(context, '/state');
      else if (kIsWeb)
        Navigator.pushReplacementNamed(context, '/web');
      else if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.fuchsia)
        Navigator.pushReplacementNamed(context, '/desktop');
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
          child: Image.asset(
            'assets/images/logo.png',
            height: 7 * SizeConfig.imageSizeMultiplier,
            filterQuality: FilterQuality.none,
          ),
        ),
      );
}
