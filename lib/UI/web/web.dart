import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Future<void> tokenLogin(String idToken) async {
    try {
      await mAuth.signInWithCustomToken(idToken).then(
        (UserCredential value) {
          loggerNoStack.i(value);
        },
      ).onError((dynamic error, StackTrace stackTrace) {
        loggerNoStack.e(error.toString());
      });
    } catch (e) {
      loggerNoStack.e(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    timerFunc();
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('TempUserID')
        .doc(generatedString);

    FirebaseFirestore.instance
        .collection('TempUserID')
        .doc(generatedString)
        .snapshots()
        .listen((DocumentSnapshot event) async {
      if (event.exists) {
        if (generatedString == docRef.id.toString()) {
          // await tokenLogin(event.data()!['token']);
          GoogleSignInProvider googleProvider =
              Provider.of<GoogleSignInProvider>(context, listen: false);
          googleProvider.login();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    return Scaffold(
      body: StreamBuilder<Object?>(
        stream: FirebaseFirestore.instance
            .collection('TempUserID')
            .doc(generatedString)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(),
            );
          return Stack(
            children: <Widget>[
              Center(
                child: Container(
                  height: 500,
                  width: 350,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FittedBox(
                        child: QrImage(
                          data: encryptedString,
                          version: 7,
                          size: 40 * SizeConfig.widthMultiplier,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Hero(
                  tag: 'logo',
                  child: Lottie.asset(
                    'assets/lottie/fingerprint.json',
                    height: 10 * SizeConfig.imageSizeMultiplier,
                    reverse: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
