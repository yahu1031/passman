import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/assets.dart';
import 'package:passman/Components/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void platforms() {
    Platform.isAndroid || Platform.isIOS
        ? Navigator.pushReplacementNamed(context, '/mobile')
        : (Platform.isWindows ||
                Platform.isMacOS ||
                Platform.isLinux ||
                Platform.isFuchsia)
            ? Navigator.pushReplacementNamed(context, '/desktop')
            : Navigator.pushReplacementNamed(context, '/web');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
              LottieFiles.fingerprint,
              repeat: false,
              animate: true,
              height: 50 * SizeConfig.imageSizeMultiplier,
            ),
            Text(
              'Password Manager',
              style: GoogleFonts.poppins(
                fontSize: 5.0 * SizeConfig.textMultiplier,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
