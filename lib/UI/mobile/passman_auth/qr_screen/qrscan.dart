import 'dart:async';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/mobile/passman_auth/qr_screen/web_logged_in_qr_screen.dart';
import 'package:passman/services/decryption.dart';
import 'package:passman/services/random.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScan extends StatefulWidget {
  const QRScan({Key? key}) : super(key: key);
  @override
  _QRScanState createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flash = false;
  final Decryption decryption = Decryption();
  final RandomNumberGenerator randomNumberGenerator = RandomNumberGenerator();
  late String generatedString;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  QRViewController? controller;
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  bool isWebLoggedin = false;
  FirebaseAuth mAuth = FirebaseAuth.instance;
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (platformExceptionError) {
      throw platformExceptionError.message.toString();
    }

    if (!mounted) {
      return Future<void>.value();
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  final double scanArea = 70 * SizeConfig.widthMultiplier;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    userDataColRef.doc(uuid).snapshots().listen((DocumentSnapshot event) async {
      if (event.exists) {
        if (event.data()!['web_login'] == true) {
          setState(() {
            isWebLoggedin = true;
          });
        } else {
          setState(() {
            isWebLoggedin = false;
          });
          await controller?.resumeCamera();
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: _connectionStatus != ConnectivityResult.none
                ? isWebLoggedin
                    ? WebLoggedinQRScreen()
                    : Stack(
                        children: <Widget>[
                          QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                            overlay: QrScannerOverlayShape(
                              borderRadius: 10,
                              borderLength: 30,
                              borderWidth: 10,
                              cutOutSize: scanArea,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              onPressed: () async {
                                await controller?.toggleFlash();
                                setState(
                                  () {
                                    flash = !flash;
                                  },
                                );
                              },
                              icon: FutureBuilder<bool?>(
                                future: controller?.getFlashStatus(),
                                builder: (BuildContext context,
                                        AsyncSnapshot<bool?> snapshot) =>
                                    Icon(
                                  flash
                                      ? const IconData(
                                          0xea51,
                                          fontFamily: 'IconsFont',
                                        )
                                      : const IconData(
                                          0xea50,
                                          fontFamily: 'IconsFont',
                                        ),
                                  color: flash
                                      ? Colors.white
                                      : Colors.grey[300]!.withOpacity(0.3),
                                  size: 10 * SizeConfig.imageSizeMultiplier,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                const IconData(
                                          0xeb55,
                                          fontFamily: 'IconsFont',
                                        ),
                                color: Colors.white,
                                size: 5 * SizeConfig.imageSizeMultiplier,
                              ),
                            ),
                          ),
                        ],
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Lottie.asset(LottieFiles.network),
                      Text(
                        'Sorry, check internet connection',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 2 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );

  Future<void> codeLogin(Barcode? result) async {
    Decryption decryption = Decryption();
    String code = decryption.stringDecryption(result!.code.toString());
    String uuid = mAuth.currentUser!.uid;
    try {
      await qrColRef.doc(code).set(<String, dynamic>{
        'flag': false,
        'logged_in_time': Timestamp.now(),
        'uid': uuid
      }).onError((dynamic signinError, StackTrace stackTrace) {
        throw signinError.toString();
      }).catchError((dynamic onSigninError) {
        throw onSigninError.toString();
      });
    } catch (e) {
      throw e.toString;
    }
    Center(
      child: Container(
        child: const CircularProgressIndicator(),
      ),
    );
  }

  void _onQRViewCreated(QRViewController? controller) {
    setState(() {
      this.controller = controller;
    });
    controller?.scannedDataStream.listen((Barcode scanData) async {
      await controller.pauseCamera();
      await codeLogin(scanData);
    });
  }
}
