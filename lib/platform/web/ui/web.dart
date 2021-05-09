import 'dart:async';
import 'package:passman/platform/web/model/location_model.dart';
import 'package:location/location.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/platform/web/services/internet_services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:passman/services/auth.dart';
import 'package:passman/platform/web/services/launchers.dart';
import 'package:passman/platform/web/services/token_gen.dart';
import 'package:passman/services/crypto/encryption.dart';
import 'package:passman/utils/constants.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({Key? key}) : super(key: key);
  @override
  _WebHomeScreenState createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  StreamSubscription<DocumentSnapshot>? _listenToScans;
  String? generatedToken, encryptedToken;
  bool isPin = false, stringMatched = false, isStarted = true;
  Timer? timer;
  GoogleSignInProvider? gAuth;
  void timerFunc(TokenGenerator token, Encryption encToken) {
    timer = Timer.periodic(const Duration(seconds: 100), (Timer timer) {
      if (mounted) {
        setState(() {
          generatedToken = token.randomStringGenerator();
          encryptedToken = encToken.stringEncryption(generatedToken!).base64;
        });
      }
    });
  }

  Location location = Location();

  @override
  void initState() {
    super.initState();
    gAuth = Provider.of<GoogleSignInProvider>(context, listen: false);
    generatedToken = TokenGenerator().randomStringGenerator();
    encryptedToken = encryption.stringEncryption(generatedToken!).base64;
    TokenGenerator token = Provider.of<TokenGenerator>(context, listen: false);
    Encryption encToken = Provider.of<Encryption>(context, listen: false);
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => timerFunc(token, encToken));
    _listenToScans = fireServer.qrColRef.doc(generatedToken).snapshots().listen(
      (DocumentSnapshot event) async {
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) return;
        } else {
          PermissionStatus _permissionGranted = await location.hasPermission();
          if (_permissionGranted == PermissionStatus.granted) {
            LocationData _location = await location.getLocation();
            LocationInfo locationData = await FetchLocation()
                .getLocationDetails(_location.latitude!, _location.longitude!);
            debugPrint(locationData.address!.village);
            setState(() {
              area = locationData.address!.village!;
            });
          } else {
            _permissionGranted = await location.requestPermission();
          }
        }
        if (event.exists) {
          if (generatedToken ==
              fireServer.qrColRef.doc(generatedToken).id.toString()) {
            try {
              await gAuth!
                  .login()
                  .whenComplete(() async {
                    if (fireServer.mAuth.currentUser != null) {
                      if (event.data()!['uid'] !=
                          fireServer.mAuth.currentUser!.uid) {
                        await gAuth!.logout();
                        if (mounted) {
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.appMainColor),
                            strokeWidth: 3,
                          ).centered();
                          await fireServer.qrColRef
                              .doc(generatedToken)
                              .delete();
                          throw 'User tried to login didn\'t match';
                        }
                      } else {
                        await fireServer.qrColRef.doc(generatedToken).delete();
                      }
                    }
                  })
                  .onError(
                    (Object? error, StackTrace stackTrace) => Scaffold(
                      body: 'User cancelled the operation'
                          .text
                          .fontFamily('LexendDeca')
                          .semiBold
                          .black
                          .make()
                          .centered(),
                    ),
                  )
                  .catchError(
                    (dynamic onError) => Scaffold(
                      body: 'User cancelled the operation'
                          .text
                          .fontFamily('LexendDeca')
                          .semiBold
                          .black
                          .make()
                          .centered(),
                    ),
                  );
            } catch (loginErr) {
              throw loginErr.toString();
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _listenToScans?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return VxResponsive(
      fallback: ZStack(
        <Widget>[
          <Widget>[
            VxBox(
              child: FittedBox(
                child: QrImage(
                  data: encryptedToken!,
                  version: 7,
                  size: 200,
                ),
              ),
            )
                .gray100
                .height(context.screenHeight * 0.35)
                .width(context.screenHeight * 0.35)
                .p16
                .withRounded(value: 7)
                .make()
                .centered(),
            generatedToken!.selectableText.make(),
          ].vStack().centered(),
          Positioned(
            top: 20,
            left: 20,
            child: Hero(
              tag: 'logo',
              child: Lottie.asset(
                LottieFiles.fingerprint,
                height: 70,
                reverse: true,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: HStack(
              <Widget>[
                'Version : 2.7.0-alpha '
                    .text
                    .fontFamily('LexendDeca')
                    .medium
                    .black
                    .semiBold
                    .make(),
                const Icon(
                  Iconsdata.testtube,
                  color: Colors.black,
                  size: 20,
                ),
                IconButton(
                  splashRadius: 0.001,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  tooltip: 'Github repository',
                  icon: const Icon(
                    Iconsdata.github,
                    size: 20,
                  ),
                  onPressed: GitLaunch().openGitLink,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
