import 'dart:js' as js;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';

class WebGoogleLoggedin extends StatefulWidget {
  @override
  _WebGoogleLoggedinState createState() => _WebGoogleLoggedinState();
}

class _WebGoogleLoggedinState extends State<WebGoogleLoggedin> {
  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset(
                    'assets/lottie/google.json',
                    height: 30 * SizeConfig.heightMultiplier,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: 'Version : 2.1.9 - Alpha ',
                          style: GoogleFonts.quicksand(
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
                      IconButton(
                        splashRadius: 0.001,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(
                          const IconData(
                            0xec1c,
                            fontFamily: 'IconsFont',
                          ),
                          size: 1.5 * SizeConfig.textMultiplier,
                        ),
                        onPressed: () {
                          js.context.callMethod(
                            'open',
                            <String>['https://github.com/yahu1031/passman'],
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              tooltip: 'Log out as ${provider.getCurrentUser().toUpperCase()}.',
              icon: const Icon(TablerIcons.logout),
              onPressed: () {
                provider.logout();
              },
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Tooltip(
              message: provider.getCurrentUser().toUpperCase(),
              child: CircleAvatar(
                backgroundImage: provider.getUserImage() as ImageProvider,
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                foregroundImage: provider.getUserImage() as ImageProvider,
                minRadius: 4 * SizeConfig.imageSizeMultiplier,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
