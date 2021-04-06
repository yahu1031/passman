import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/state_check.dart';

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
            if (snapshot.hasData) return const StateCheck();
            return Center(
              child: Hero(
                tag: 'logo',
                child: Lottie.asset(
                  LottieFiles.fingerprint,
                  height: 30 * SizeConfig.imageSizeMultiplier,
                ),
              ),
            );
          },
        ),
  );
}
