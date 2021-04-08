import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/constants.dart';
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
  bool _userHasData = false;
  void _loginWithImage() {
    Navigator.pushNamed(context, PageRoutes.routePassmanLogin);
  }

  Future<void> checkUserDB() async {
    String? uuid = mAuth.currentUser!.uid;
    String? name = mAuth.currentUser!.displayName;
    DocumentReference userDataDocRef =
        FirebaseFirestore.instance.collection('UserData').doc(uuid);
    try {
      DocumentSnapshot checkData = await userDataDocRef.get();
      if (checkData.exists) {
        await userDataDocRef.update(<String, dynamic>{
          'name': name,
          'web_login': false,
          'platform': 'No records',
          'logged_in_time': 'No records',
          'ip': 'No records'
        }).onError((dynamic firestoreError, StackTrace stackTrace) {
          log(firestoreError.toString());
        }).catchError((dynamic onFirestoreError) {
          log(onFirestoreError.toString());
        });
      } else {
        await userDataDocRef.set(<String, dynamic>{
          'name': name,
          'web_login': false,
          'img': 'No records',
          'platform': 'No records',
          'logged_in_time': 'No records',
          'ip': 'No records'
        }).onError((dynamic firestoreError, StackTrace stackTrace) {
          log(firestoreError.toString());
        }).catchError((dynamic onFirestoreError) {
          log(onFirestoreError.toString());
        });
      }
    } catch (err) {
      log(err.toString());
    }
  }

  String? tempPlat;
  void _signupWithImage() {
    Navigator.restorablePushReplacementNamed(
      context,
      PageRoutes.routePassmanSignup,
    );
  }

  @override
  void initState() {
    super.initState();
    _userHasData = false;
    if (!kIsWeb) {
      checkUserDB();
    }
    String file = '${mAuth.currentUser!.uid}.png';
    storageRef
        .child('UserImgData/$file')
        .getDownloadURL()
        .then((String? value) {
      if (mounted) {
        setState(() {
          value != null ? _userHasData = true : _userHasData = false;
        });
      }
    });
    _loginTapGesture = TapGestureRecognizer()..onTap = _loginWithImage;
    _signupTapGesture = TapGestureRecognizer()..onTap = _signupWithImage;
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
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
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 2 * SizeConfig.textMultiplier,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: provider.getCurrentUser().toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
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
                        IconData(
                          0xeb3a,
                          fontFamily: 'IconsFont',
                        ),
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, PageRoutes.routeQRScan);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Column(
                      children: <Widget>[
                        !_userHasData
                            ? RichText(
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                text: TextSpan(
                                  text: 'You seems new here ',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 1.75 * SizeConfig.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'SIGNUP',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[400],
                                      ),
                                      recognizer: _signupTapGesture,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                        SizedBox(
                          height: !_userHasData
                              ? 0
                              : 2 * SizeConfig.heightMultiplier,
                        ),
                        _userHasData
                            ? RichText(
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                text: TextSpan(
                                  text: 'You seems old user ',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 1.75 * SizeConfig.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'LOGIN',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue[400],
                                      ),
                                      recognizer: _loginTapGesture,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                        SizedBox(
                          height: !_userHasData
                              ? 0
                              : 2 * SizeConfig.heightMultiplier,
                        ),
                        _userHasData
                            ? RichText(
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                text: TextSpan(
                                  text: 'Wanna change master image? ',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 1.75 * SizeConfig.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'CHANGE IMAGE',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[400],
                                      ),
                                      recognizer: _signupTapGesture,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                height: 0,
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
