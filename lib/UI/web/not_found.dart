import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/other.dart';
import 'package:passman/services/state_check.dart';

class NotFoundScreen extends StatefulWidget {
  NotFoundScreen({Key? key}) : super(key: key);
  @override
  _NotFoundScreenState createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/not_found.png',
                    height: 40 * SizeConfig.imageSizeMultiplier,
                  ),
                  Text(
                    'Seems you are lost',
                    style: TextStyle(
                      fontFamily: 'LexendDeca',
                      fontSize: 2 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 10 * SizeConfig.heightMultiplier,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      primary: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const StateCheck(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(
                        'Go back to home',
                        style: TextStyle(
                          color: Colors.white,
                              fontFamily: 'LexendDeca',
                          fontWeight: FontWeight.w500,
                          fontSize: 1 * SizeConfig.textMultiplier,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Hero(
                tag: 'logo',
                child: Lottie.asset(
                  LottieFiles.fingerprint,
                  height: 10 * SizeConfig.imageSizeMultiplier,
                  reverse: true,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Version : 2.6.0-alpha.2 ',
                    style: TextStyle(
                      fontFamily: 'LexendDeca',
                      fontSize: 1 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Iconsdata.testtube,
                    color: Colors.black,
                    size: 1.5 * SizeConfig.textMultiplier,
                  ),
                  IconButton(
                    splashRadius: 0.001,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: Icon(
                      Iconsdata.github,
                      size: 1.5 * SizeConfig.textMultiplier,
                    ),
                    // onPressed: _openGitLink,
                    onPressed: GitLaunch().openGitLink,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
