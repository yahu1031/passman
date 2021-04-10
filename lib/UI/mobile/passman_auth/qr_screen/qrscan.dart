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
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/mobile/passman_auth/qr_screen/web_logged_in_qr_screen.dart';
import 'package:passman/services/decryption.dart';
import 'package:passman/services/random.dart';
import 'package:passman/services/utilities/enums.dart';
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
  String? generatedString;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  LoadingState? loadingState;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  QRViewController? controller;
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  bool isWebLoggedin = false, isLoading = false;
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
    loadingState = LoadingState.PENDING;
    isLoading = false;
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    fireServer.userDataColRef
        .doc(uuid)
        .snapshots()
        .listen((DocumentSnapshot event) async {
      if (event.exists) {
        if (event.data()!['web_login'] == true) {
          if (mounted) {
            setState(() {
              isWebLoggedin = true;
              loadingState = LoadingState.SUCCESS;
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isWebLoggedin = false;
              loadingState = LoadingState.SUCCESS;
              isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _connectivitySubscription?.cancel();
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
                    : loadingState == LoadingState.LOADING || isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
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
                                          ? Iconsdata.flashOn
                                          : Iconsdata.flashOff,
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
                                    Iconsdata.x,
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
                        style: TextStyle(
                          fontFamily: 'LexendDeca',
                          fontSize: 2 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );

  Future<void> codeLogin(Barcode? result) async {
    String code = decryption.stringDecryption(result!.code.toString());
    try {
      await fireServer.qrColRef.doc(code).set(<String, dynamic>{
        'flag': false,
        'logged_in_time': Timestamp.now(),
        'uid': uuid
      }).whenComplete(() {
        setState(() {
          loadingState == LoadingState.SUCCESS;
        });
      }).onError((dynamic signinError, StackTrace stackTrace) {
        throw signinError.toString();
      }).catchError((dynamic onSigninError) {
        throw onSigninError.toString();
      });
    } catch (e) {
      throw e.toString;
    }
  }

  void _onQRViewCreated(QRViewController? controller) {
    setState(() {
      this.controller = controller;
    });
    controller?.scannedDataStream.listen((Barcode scanData) async {
      // await controller.pauseCamera();
      controller.dispose();
      setState(() {
        loadingState == LoadingState.LOADING;
        isLoading = true;
      });
      await codeLogin(scanData);
    });
  }
}
