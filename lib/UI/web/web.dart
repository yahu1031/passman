import 'package:passman/Components/constants.dart';
import 'package:passman/services/other.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:passman/services/en_de_cryption/encryption.dart';
import 'package:passman/services/random.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Web extends StatefulWidget {
  const Web({Key? key}) : super(key: key);
  @override
  _WebState createState() => _WebState();
}

class _WebState extends State<Web> with TickerProviderStateMixin {
  FirebaseAuth mAuth = FirebaseAuth.instance;

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(5.0),
  );
  final Encryption encryption = Encryption();
  late AnimationController _controller;
  late StreamSubscription<DocumentSnapshot> _listenToScans;
  late String generatedString, encryptedString;
  bool isPin = false, stringMatched = false, isStarted = true;
  late Timer timer;

  void timerFunc() {
    generatedString = RandomNumberGenerator().randomStringGenerator(6);
    encryptedString = encryption.stringEncryption(generatedString).base64;
    timer = Timer.periodic(const Duration(seconds: 100), (Timer timer) {
      setState(() {
        generatedString = RandomNumberGenerator().randomStringGenerator(6);
        encryptedString = encryption.stringEncryption(generatedString).base64;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    timerFunc();
    DocumentReference docRef = fireServer.qrColRef.doc(generatedString);
    _listenToScans = docRef.snapshots().listen(
      (DocumentSnapshot event) async {
        if (event.exists) {
          // ignore: avoid_print
          print('Login token :$generatedString');
          if (generatedString == docRef.id.toString()) {
            try {
              GoogleSignInProvider googleProvider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              await googleProvider
                  .login()
                  .whenComplete(
                    () async {
                      if (mAuth.currentUser != null) {
                        if (event.data()!['uid'] != mAuth.currentUser!.uid) {
                          await googleProvider.logout();
                          if (!mounted) {
                            const CircularProgressIndicator();
                            await fireServer.qrColRef
                                .doc(generatedString)
                                .delete();
                            throw 'User tried to login didn\'t match';
                          }
                        } else {
                          await fireServer.qrColRef
                              .doc(generatedString)
                              .delete();
                        }
                      }
                    },
                  )
                  .onError(
                    (Object? error, StackTrace stackTrace) => Scaffold(
                      body: Center(
                        child: Text(
                          'User cancelled the operation',
                          style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontSize: 1.75 * SizeConfig.textMultiplier,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                  .catchError(
                    (dynamic onError) {
                      Scaffold(
                        body: Center(
                          child: Text(
                            'User cancelled the operation',
                            style: TextStyle(
                              fontFamily: 'LexendDeca',
                              fontSize: 1.75 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
            } catch (loginErr) {
              // ignore: avoid_print
              print(loginErr.toString());
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    _listenToScans.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<Object?>(
          stream: fireServer.qrColRef.doc(generatedString).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    height: 35 * SizeConfig.imageSizeMultiplier,
                    width: 35 * SizeConfig.imageSizeMultiplier,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: FittedBox(
                      child: QrImage(
                        data: encryptedString,
                        version: 7,
                        size: 40 * SizeConfig.widthMultiplier,
                      ),
                    ),
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
                    children: <Widget>[
                      Text(
                        'Version : 2.6.0-alpha.5 ',
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
                        tooltip: 'Github repository',
                        icon: Icon(
                          Iconsdata.github,
                          size: 1.5 * SizeConfig.textMultiplier,
                        ),
                        onPressed: GitLaunch().openGitLink,
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
}
