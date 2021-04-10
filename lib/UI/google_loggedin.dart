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
        if (checkData.data()!['web_login'] == false) {
          await userDataDocRef.update(<String, dynamic>{
            'name': name,
            'web_login': false,
            'platform': 'No records',
            'browser': 'No records',
            'logged_in_time': 'No records',
            'ip': 'No records',
            'location': 'No records',
          }).onError((dynamic firestoreError, StackTrace stackTrace) {
            throw firestoreError.toString();
          }).catchError((dynamic onFirestoreError) {
            throw onFirestoreError.toString();
          });
        }
      } else {
        await userDataDocRef.set(<String, dynamic>{
          'name': name,
          'web_login': false,
          'img': 'No records',
          'platform': 'No records',
          'browser': 'No records',
          'logged_in_time': 'No records',
          'location': 'No records',
          'ip': 'No records'
        }).onError((dynamic firestoreError, StackTrace stackTrace) {
          throw firestoreError.toString();
        }).catchError((dynamic onFirestoreError) {
          throw onFirestoreError.toString();
        });
      }
    } catch (err) {
      throw err.toString();
    }
  }

  String? tempPlat;
  void _signupWithImage() {
    Navigator.pushNamed(
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

    fireServer.storageRef
        .child('UserImgData/$file')
        .getDownloadURL()
        .then((String? value) async {
      DocumentSnapshot userImgData =
          await fireServer.userDataColRef.doc(mAuth.currentUser!.uid).get();
      if (userImgData.data()!['img'] == 'No records') {
        if (mounted) {
          setState(() {
            _userHasData = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _userHasData = true;
        });
      }
    }).onError((dynamic error, StackTrace stackTrace) {
      throw error.toString();
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
                              fontFamily: 'LexendDeca',
                              fontSize: 2 * SizeConfig.textMultiplier,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: mAuth.currentUser!.displayName!
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'LexendDeca',
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
                        message: mAuth.currentUser!.displayName!.toUpperCase(),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            mAuth.currentUser!.photoURL.toString(),
                          ),
                          foregroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          foregroundImage: NetworkImage(
                            mAuth.currentUser!.photoURL.toString(),
                          ),
                          minRadius: 6 * SizeConfig.imageSizeMultiplier,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _userHasData
                        ? IconButton(
                            tooltip: 'Login to Computer',
                            icon: const Icon(
                              Iconsdata.device,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, PageRoutes.routeQRScan);
                            },
                          )
                        : const SizedBox(height: 0, width: 0),
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
                                    fontFamily: 'LexendDeca',
                                    fontSize: 1.75 * SizeConfig.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'SIGNUP',
                                      style: TextStyle(
                                        fontFamily: 'LexendDeca',
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
                                    fontFamily: 'LexendDeca',
                                    fontSize: 1.75 * SizeConfig.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'LOGIN',
                                      style: TextStyle(
                                        fontFamily: 'LexendDeca',
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
                                    fontFamily: 'LexendDeca',
                                    fontSize: 1.75 * SizeConfig.textMultiplier,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'CHANGE IMAGE',
                                      style: TextStyle(
                                        fontFamily: 'LexendDeca',
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
