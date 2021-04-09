import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:passman/Components/icons/google.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';

class Mobile extends StatefulWidget {
  const Mobile({Key? key}) : super(key: key);
  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  final GoogleSignInProvider auth = GoogleSignInProvider();

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
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
                      provider.login();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Signin with ',
                          style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontSize: 2 * SizeConfig.textMultiplier,
                            fontWeight: FontWeight.w900,
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
