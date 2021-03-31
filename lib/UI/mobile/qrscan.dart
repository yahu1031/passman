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
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/decryption.dart';
import 'package:passman/services/encryption.dart';
import 'package:passman/services/random.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class QRScan extends StatefulWidget {
  const QRScan({Key? key}) : super(key: key);
  static const String id = '/qrcode';
  @override
  _QRScanState createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  bool flash = false;
  final Decryption decryption = Decryption();
  final RandomNumberGenerator randomNumberGenerator = RandomNumberGenerator();
  late String generatedString;
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  // ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  QRViewController? controller;

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (platformExceptionError) {
      logger.e(platformExceptionError.message.toString());
      return;
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
  }

  @override
  void dispose() {
    controller?.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
                ? Stack(
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
                              flash ? TablerIcons.bulb : TablerIcons.bulb_off,
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
                            TablerIcons.x,
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
                      Lottie.asset('assets/lottie/network.json'),
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

  Future<String> getID() async {
    User? tokenResult = await _firebaseAuth.currentUser;
    String? idToken = await tokenResult!.getIdToken();
    return idToken;
  }

  Future<void> showCode(Barcode? result) async {
    Decryption decryption = Decryption();
    Encryption encryption = Encryption();
    String getCode = await getID();
    String code = decryption.stringDecryption(result!.code.toString());
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Code',
          style: GoogleFonts.lexendDeca(
            fontSize: 5 * SizeConfig.textMultiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          (result.code.toString().isNotEmpty) ? code : 'Scan the code',
          style: GoogleFonts.lexendDeca(
            fontSize: 3 * SizeConfig.textMultiplier,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await controller?.resumeCamera();
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
  }

  void _onQRViewCreated(QRViewController? controller) {
    setState(() {
      this.controller = controller;
    });
    controller?.scannedDataStream.listen((Barcode scanData) async {
      setState(() {
        result = scanData;
      });
      await controller.pauseCamera();
      try {
        FirebaseFirestore.instance
            .collection('TempUserID')
            .doc(result.code)
            .set(<String, dynamic>{'token': 'null', 'flag': false}).onError(
                (dynamic signinError, StackTrace stackTrace) {
          print(signinError.toString());
        }).catchError((dynamic onSigninError) {
          print(onSigninError.toString());
        });
      } catch (e) {
        print(e.toString);
      }
      showCode(result);
    });
  }
}
