import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';

class SorryPage extends StatefulWidget {
  @override
  _SorryPageState createState() => _SorryPageState();
}

class _SorryPageState extends State<SorryPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(
                LottieFiles.sorry,
                width: 50 * SizeConfig.widthMultiplier,
              ),
              Text(
                'Sorry wrong password',
                style: TextStyle(
                  fontFamily: 'LexendDeca',
                  fontSize: 1.5 * SizeConfig.textMultiplier,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
    );
}
