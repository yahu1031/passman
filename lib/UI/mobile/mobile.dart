import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passman/Components/icons/google.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

class Mobile extends StatefulWidget {
  const Mobile({Key key}) : super(key: key);
  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  final GoogleSignInProvider auth = GoogleSignInProvider();

  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      final GoogleSignInProvider provider =
                          Provider.of<GoogleSignInProvider>(context,
                              listen: false);
                      provider.login();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Signin with ',
                          style: GoogleFonts.lexendDeca(
                            fontSize: 2 * SizeConfig.textMultiplier,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CustomPaint(
                          size: Size(
                              12 * SizeConfig.widthMultiplier,
                              (2 *
                                      SizeConfig.heightMultiplier *
                                      1.0203206813238201)
                                  .toDouble()),
                          painter: GoogleIcon(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
