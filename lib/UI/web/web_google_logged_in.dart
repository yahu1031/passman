import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/services/other.dart';
import 'package:provider/provider.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/device_info.dart';
import 'package:passman/services/authentication.dart';
import 'package:passman/services/internet_services.dart';

class WebGoogleLoggedin extends StatefulWidget {
  @override
  _WebGoogleLoggedinState createState() => _WebGoogleLoggedinState();
}

class _WebGoogleLoggedinState extends State<WebGoogleLoggedin> {
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  FetchLocation fetchLocation = FetchLocation();
  // double? _latitude, _longitude;
  bool isDataFetched = false;



  Future<void> updateDB(GoogleSignInProvider provider) async {
    fireServer.userDataColRef
        .doc(uuid)
        .snapshots()
        .listen((DocumentSnapshot event) async {
      if (fireServer.mAuth.currentUser != null) {
        // await Dialogs.yesAbortDialog(context, 'title', '$area1', () async {
        //   detectUserLocation(
        //     allowInterop(
        //       (GeolocationPosition pos) {
        //         setState(() {
        //           _latitude = pos.coords.latitude;
        //           _longitude = pos.coords.longitude;
        //         });
        //         throw 'got locations';
        //       },
        //     ),
        //   );
        //   // ignore: avoid_print
        //   print('$_latitude, $_longitude');
        //   LocationInfo locationData =
        //       await FetchLocation()
        // .getLocationDetails(_latitude!, _longitude!);
        //   // ignore: avoid_print
        //   print(locationData.address!.village);
        // });
        String? ipAddress = await FetchIP.getIP();
        PlatformInfo loggedInPlatform = await platformInfo;
        if (event.exists) {
          if (event.data()!['ip'] == 'No records' ||
              event.data()!['logged_in_time'] == 'No records' ||
              event.data()!['web_login'] == false ||
              event.data()!['platform'] == 'No records') {
            try {
              await fireServer.userDataColRef.doc(uuid).update(
                <String, dynamic>{
                  'web_login': true,
                  'platform': loggedInPlatform.os,
                  'browser': loggedInPlatform.browser,
                  'ip': ipAddress,
                  'location': 'area',
                  'logged_in_time': Timestamp.now()
                },
              ).whenComplete(() {
                if (mounted) {
                  setState(() {
                    isDataFetched = true;
                  });
                }
              }).catchError((dynamic onError) {
                if (mounted) {
                  setState(() {
                    isDataFetched = false;
                  });
                }
                provider.logout();
                throw 'Update catch error: ${onError.toString()}';
              }).onError((Object? error, StackTrace stackTrace) {
                if (mounted) {
                  setState(() {
                    isDataFetched = false;
                  });
                }
                provider.logout();
                throw 'Update on error: ${error.toString()}';
              });
            } catch (err) {
              if (mounted) {
                setState(() {
                  isDataFetched = false;
                });
              }
              await provider.logout();
              throw 'Update try catch error: ${err.toString()}';
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    updateDB(provider);
  }

  String? area1;
  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);

    return Scaffold(
      body: !isDataFetched
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  SizedBox(height: 5 * SizeConfig.heightMultiplier),
                  Text(
                    'Fetching your data...',
                    style: TextStyle(
                      fontFamily: 'LexendDeca',
                      fontSize: 1.75 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: <Widget>[
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Lottie.asset(
                          LottieFiles.google,
                          height: 30 * SizeConfig.heightMultiplier,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              icon: Icon(
                                Iconsdata.github,
                                size: 1.5 * SizeConfig.textMultiplier,
                              ),
                              // onPressed: _openGitLink,
                              onPressed: GitLaunch().openGitLink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    splashRadius: 0.001,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    tooltip: '''
Log out as ${fireServer.mAuth.currentUser!.displayName!.toUpperCase()}.''',
                    icon: const Icon(
                      Iconsdata.logout,
                    ),
                    onPressed: () async {
                      String? userUID = fireServer.mAuth.currentUser!.uid;
                      await provider.logout();
                      await fireServer.userDataColRef.doc(userUID).update(
                        <String, dynamic>{
                          'web_login': false,
                          'platform': 'No records',
                          'browser': 'No records',
                          'logged_in_time': 'No records',
                          'location': 'No records',
                          'ip': 'No records'
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Tooltip(
                    message: fireServer.mAuth.currentUser!.displayName!
                        .toUpperCase(),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        fireServer.mAuth.currentUser!.photoURL!,
                      ),
                      foregroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      foregroundImage: NetworkImage(
                        fireServer.mAuth.currentUser!.photoURL!,
                      ),
                      minRadius: 4 * SizeConfig.imageSizeMultiplier,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
