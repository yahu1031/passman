import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/services/state_check.dart';
import 'package:passman/utils/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  Future<bool> future() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    return true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<bool>(
          future: future.call(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) return StateCheck();
            return Center(
              child: Hero(
                tag: 'logo',
                child: Lottie.asset(
                  LottieFiles.fingerprint,
                  height: 150,
                ),
              ),
            );
          },
        ),
      );
}
