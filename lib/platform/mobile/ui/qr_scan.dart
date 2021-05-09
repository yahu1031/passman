import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/platform/web/model/user_data.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:passman/services/crypto/decryption.dart';
import 'package:passman/utils/constants.dart';

class QrScan extends StatefulWidget {
  @override
  _QrScanState createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> with TickerProviderStateMixin {
  String? plat, browser;
  IconData? platformIcons, browserIcons;
  // User uid
  final String uuid = fireServer.mAuth.currentUser!.uid;

  // Loading state
  LoadingState? loadingState;

  // boolean value for web logged in or not and
  // is Loading or not
  bool isWebLoggedin = false, isLoading = false, flash = false;

  // Controls how one widget replaces another widget in the tree.
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // QR view controller
  QRViewController? controller;

  // Animation contoller for lottie
  AnimationController? lottieController;

  // Decryption object
  Decryption decryption = Decryption();

  // Listening to the User database as stream
  StreamSubscription<DocumentSnapshot>? _listenToDB;
  StreamSubscription<Barcode>? barCodeStream;

  // _onQRViewCreated function will be called on when the view is created
  void _onQRViewCreated(QRViewController? controller) {
    setState(() {
      this.controller = controller;
    });
    barCodeStream =
        controller?.scannedDataStream.listen((Barcode scanData) async {
      await controller.pauseCamera();
      lottieController?.stop();
      try {
        String code = decryption.stringDecryption(scanData.code);
        await fireServer.qrColRef.doc(code).set(<String, dynamic>{
          'token': code,
          'logged_in_time': Timestamp.now(),
          'uid': uuid
        }).then((_) async {
          await fireServer.userDataColRef.doc(uuid).update(<String, dynamic>{
            'token': code,
            'logged_in_time': Timestamp.now(),
            // 'web_login': true,
          });
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
        throw e.toString();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadingState = LoadingState.PENDING;
    lottieController = AnimationController(vsync: this);
    _listenToDB = fireServer.userDataColRef
        .doc(uuid)
        .snapshots()
        .listen((DocumentSnapshot event) {
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


  // In order to get hot reload to work
  // we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    lottieController?.dispose();
    controller?.dispose();
    barCodeStream?.cancel();
    _listenToDB?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: StreamBuilder<DocumentSnapshot>(
              stream: fireServer.userDataColRef.doc(uuid).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  UserData userData = UserData.fromDocument(snapshot.data!);
                  plat = userData.platform!;
                  browser = userData.browser;
                  List<String>? time =
                      userData.logged_in_time!.toDate().toString().split(':');
                  time.removeLast();
                  plat!.toLowerCase() == 'windows'
                      ? platformIcons = Iconsdata.windows
                      : plat!.toLowerCase() == 'macos'
                          ? platformIcons = Iconsdata.mac
                          : plat!.toLowerCase() == 'linux'
                              ? platformIcons = Iconsdata.linux
                              : platformIcons = Iconsdata.linux;

                  browser!.toLowerCase() == 'safari'
                      ? browserIcons = Iconsdata.safari
                      : browser!.toLowerCase() == 'chrome'
                          ? browserIcons = Iconsdata.chrome
                          : browser!.toLowerCase() == 'edge'
                              ? browserIcons = Iconsdata.edge
                              : browser!.toLowerCase() == 'opera'
                                  ? browserIcons = Iconsdata.opera
                                  : browser!.toLowerCase() == 'firefox'
                                      ? browserIcons = Iconsdata.firefox
                                      : browserIcons = Iconsdata.browser;
                  if (snapshot.data!.exists) {
                    if (snapshot.data!.data()!['web_login'] == false) {
                      return ZStack(
                        <Widget>[
                          QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                            overlay: QrScannerOverlayShape(
                              overlayColor: Colors.white,
                              borderColor: AppColors.appMainColor,
                              borderRadius: 10,
                              borderLength: 100,
                              borderWidth: 2,
                              cutOutSize: context.mq.size.width * 0.7,
                            ),
                          ),
                          Lottie.asset(
                            'assets/lottie/scanner.json',
                            controller: lottieController,
                            repeat: true,
                            onLoaded: (LottieComposition composition) {
                              lottieController!
                                ..duration = composition.duration
                                ..forward()
                                ..repeat();
                            },
                            width: context.mq.size.width * 0.7,
                          ).centered(),
                          IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
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
                                flash ? Iconsdata.flashOn : Iconsdata.flashOff,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ).positioned(
                            bottom: context.mq.size.height * 0.1,
                            right: 0,
                            left: 0,
                          ),
                          IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Iconsdata.x,
                              color: Colors.black,
                              size: 20,
                            ),
                          ).positioned(top: 20, right: 20),
                          Hero(
                            tag: 'dp',
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(
                                  fireServer.mAuth.currentUser!.photoURL!),
                            ),
                          ).positioned(top: 20, left: 20),
                        ],
                      ).centered();
                    } else {
                      return ZStack(
                        <Widget>[
                          VStack(
                            <Widget>[
                              '${userData.ip}'.text.center.make().centered(),
                              '${userData.browser}'
                                  .text
                                  .center
                                  .make()
                                  .centered(),
                              '${userData.location}'
                                  .text
                                  .center
                                  .make()
                                  .centered(),
                              '${userData.platform}'
                                  .text
                                  .center
                                  .make()
                                  .centered(),
                              '${userData.logged_in_time!.toDate()}'
                                  .text
                                  .center
                                  .make()
                                  .centered(),
                            ],
                            alignment: MainAxisAlignment.center,
                            crossAlignment: CrossAxisAlignment.center,
                            axisSize: MainAxisSize.max,
                          ),
                          IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Iconsdata.x,
                              color: Colors.black,
                              size: 20,
                            ),
                          ).positioned(top: 20, right: 20),
                          Hero(
                            tag: 'dp',
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(
                                  fireServer.mAuth.currentUser!.photoURL!),
                            ),
                          ).positioned(top: 20, left: 20),
                        ],
                      ).centered();
                      // });
                    }
                  } else if (snapshot.data == null || !snapshot.data!.exists) {
                    return ZStack(
                      <Widget>[
                        QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            overlayColor: Colors.white,
                            borderColor: AppColors.appMainColor,
                            borderRadius: 10,
                            borderLength: 100,
                            borderWidth: 2,
                            cutOutSize: 200,
                          ),
                        ),
                        Lottie.asset(
                          'assets/lottie/scanner.json',
                          controller: lottieController,
                          repeat: true,
                          onLoaded: (LottieComposition composition) {
                            lottieController!
                              ..duration = composition.duration
                              ..forward()
                              ..repeat();
                          },
                          width: 250,
                        ).centered(),
                        IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
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
                              flash ? Iconsdata.flashOn : Iconsdata.flashOff,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ).positioned(top: 10, right: 10),
                        IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Iconsdata.x,
                            color: Colors.black,
                            size: 20,
                          ),
                        ).positioned(top: 10, left: 10),
                      ],
                    ).centered();
                  }
                } else if (!snapshot.hasData) {
                  return const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                    strokeWidth: 3,
                  ).centered();
                } else {
                  return const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                    strokeWidth: 3,
                  ).centered();
                }
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              }),
        ),
      ),
    );
  }
}
