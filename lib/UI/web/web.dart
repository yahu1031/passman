import 'package:passman/Components/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:passman/services/encryption.dart';
import 'package:passman/services/random.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Web extends StatefulWidget {
  const Web({Key? key}) : super(key: key);
  @override
  _WebState createState() => _WebState();
}

class _WebState extends State<Web> with TickerProviderStateMixin {
  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  final String _url = 'https://github.com/yahu1031/passman';
  FirebaseAuth mAuth = FirebaseAuth.instance;

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(5.0),
  );
  final Encryption encryption = Encryption();
  late AnimationController _controller;
  late String generatedString, encryptedString;
  bool isPin = false, stringMatched = false, isStarted = true;
  late Timer timer;
  Future<void> showCode(BuildContext context) async {
    try {
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            'Sorry',
            style: GoogleFonts.lexendDeca(
              fontSize: 5 * SizeConfig.textMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'User tried to login didn\'t match.',
            style: GoogleFonts.lexendDeca(
              fontSize: 3 * SizeConfig.textMultiplier,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.lexendDeca(
                  fontSize: 2 * SizeConfig.textMultiplier,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      loggerNoStack.e(e.toString());
    }
  }

  Future<void> _openGitLink() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
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
    DocumentReference docRef = qrColRef.doc(generatedString);
    docRef.snapshots().listen(
      (DocumentSnapshot event) async {
        if (event.exists) {
          if (generatedString == docRef.id.toString()) {
            GoogleSignInProvider googleProvider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
            await googleProvider
                .login()
                .whenComplete(
                  () async {
                    if (mAuth.currentUser != null) {
                      if (event.data()!['uid'] != mAuth.currentUser!.uid) {
                        await googleProvider.logout();
                        print('User tried to login didn\'t match');
                        const CircularProgressIndicator();
                        await qrColRef.doc(generatedString).delete();
                        // await showCode(context);
                      } else {
                        await qrColRef.doc(generatedString).delete();
                      }
                    }
                  },
                )
                .onError(
                  (Object? error, StackTrace stackTrace) => const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
                .catchError(
                  (dynamic onError) {
                    const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: StreamBuilder<Object?>(
        stream: qrColRef.doc(generatedString).snapshots(),
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
                    Text.rich(
                      TextSpan(
                        text: 'Version : 2.2.5-alpha ',
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
                    IconButton(
                      splashRadius: 0.001,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      tooltip: 'Github repository',
                      icon: Icon(
                        const IconData(
                          0xec1c,
                          fontFamily: 'IconsFont',
                        ),
                        size: 1.5 * SizeConfig.textMultiplier,
                      ),
                      onPressed: _openGitLink,
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
