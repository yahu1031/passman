import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:passman/services/encryption.dart';
import 'package:passman/Components/pin_field.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    timerFunc();
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
      body: Stack(
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
              child: Form(
                key: _formKey,
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
                    if (!stringMatched)
                      PinField(
                        autofocus: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        fieldsAlignment: MainAxisAlignment.spaceAround,
                        eachFieldWidth: 3 * SizeConfig.heightMultiplier,
                        eachFieldHeight: 3 * SizeConfig.heightMultiplier,
                        withCursor: true,
                        fieldsCount: 6,
                        focusNode: _pinPutFocusNode,
                        controller: _pinPutController,
                        eachFieldMargin: EdgeInsets.zero,
                        onSubmit: (String pin) {
                          if (_pinPutController.text == generatedString) {
                            setState(() {
                              isPin = true;
                              stringMatched = true;
                            });
                            timer.cancel();
                            provider.login();
                          } else {
                            setState(() {
                              isPin = false;
                              stringMatched = false;
                            });
                          }
                        },
                        submittedFieldDecoration: pinPutDecoration,
                        selectedFieldDecoration: pinPutDecoration,
                        followingFieldDecoration: pinPutDecoration,
                        pinAnimationType: PinAnimationType.scale,
                        textStyle: GoogleFonts.quicksand(
                          color: Colors.black,
                          fontSize: 2.5 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    else
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          primary: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 1 * SizeConfig.textMultiplier,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Lottie.asset(
              'assets/lottie/fingerprint.json',
              height: 10 * SizeConfig.imageSizeMultiplier,
              reverse: true,
            ),
          ),
        ],
      ),
    );
  }
}
