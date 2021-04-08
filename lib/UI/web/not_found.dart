import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
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
                      fontFamily: 'Quicksand',
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
                              fontFamily: 'Quicksand',
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
              child: Text.rich(
                TextSpan(
                  text: 'Version : 2.2.6-alpha.2 ',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 1 * SizeConfig.textMultiplier,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: '🧪',
                      style: GoogleFonts.notoSans(
                        fontSize: 1 * SizeConfig.textMultiplier,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
