import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/web/web_google_logged_in.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleLoggedInScreen extends StatefulWidget {
  const GoogleLoggedInScreen({Key? key}) : super(key: key);
  @override
  _GoogleLoggedInScreenState createState() => _GoogleLoggedInScreenState();
}

class _GoogleLoggedInScreenState extends State<GoogleLoggedInScreen> {
  late TapGestureRecognizer _loginTapGesture, _signupTapGesture;
  FirebaseAuth mAuth = FirebaseAuth.instance;
  Future<void> _loginWithImage() async {
    Navigator.pushNamed(context, '/passmanlogin');
  }

  Future<void> _signupWithImage() async {
    Navigator.pushNamed(
      context,
      '/passmansignup',
    );
  }

  // Future<String> getCustomToken(GoogleSignInProvider googleProvider) async {
  //   String token = await googleProvider.getUserToken();
  //   return token.toString();
  // }

  @override
  void initState() {
    super.initState();
    _loginTapGesture = TapGestureRecognizer()..onTap = _loginWithImage;
    _signupTapGesture = TapGestureRecognizer()..onTap = _signupWithImage;
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    // mAuth.currentUser!.getIdToken().then((String value) {
    //   print(value);
    //   return value;
    // });
    return Scaffold(
      body: SafeArea(
        child: kIsWeb
            ? WebGoogleLoggedin()
            : Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            text: 'Hello ',
                            style: GoogleFonts.quicksand(
                              fontSize: 2 * SizeConfig.textMultiplier,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: provider.getCurrentUser().toUpperCase(),
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue[400],
                                ),
                              ),
                              const TextSpan(
                                text: '.\n Glad you are here.\n',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onDoubleTap: () => provider.logout(),
                      child: Tooltip(
                        message: provider.getCurrentUser().toUpperCase(),
                        child: CircleAvatar(
                          backgroundImage:
                              provider.getUserImage() as ImageProvider,
                          foregroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          foregroundImage:
                              provider.getUserImage() as ImageProvider,
                          minRadius: 6 * SizeConfig.imageSizeMultiplier,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      tooltip: 'Login to Computer',
                      icon: const Icon(
                        TablerIcons.qrcode,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/qrscan');
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Column(
                      children: <Widget>[
                        RichText(
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            text: 'New here? ',
                            style: GoogleFonts.quicksand(
                              fontSize: 2 * SizeConfig.textMultiplier,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'LOGIN',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue[400],
                                ),
                                recognizer: _loginTapGesture,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2 * SizeConfig.heightMultiplier,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            text: 'Old user? ',
                            style: GoogleFonts.quicksand(
                              fontSize: 2 * SizeConfig.textMultiplier,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'SIGNUP',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue[400],
                                ),
                                recognizer: _signupTapGesture,
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
