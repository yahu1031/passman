import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/models/location_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/device_info.dart';
import 'package:passman/services/authentication.dart';
import 'package:passman/services/internet_services.dart';
import 'package:location/location.dart';

class WebGoogleLoggedin extends StatefulWidget {
  @override
  _WebGoogleLoggedinState createState() => _WebGoogleLoggedinState();
}

class _WebGoogleLoggedinState extends State<WebGoogleLoggedin> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  final String _url = 'https://github.com/yahu1031/passman';
  WebBrowserInfo? browserInfo;
  IconData? browserIcon, platformIcon;
  bool isDataFetched = false;
  FireServer fireServer = FireServer();
  Location location = Location();

  LocationData? _locationData;

  Future<void> _openGitLink() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  Future<String?> get locationInfo async {
    _locationData = await location.getLocation();
    print(_locationData!.latitude!);
    print(_locationData!.longitude!);
    LocationInfo locationData = await FetchLocation().getLocationDetails(
      _locationData!.latitude!,
      _locationData!.longitude!,
    );
    return locationData.address!.village;
  }

  Future<PlatformInfo> get platformInfo async {
    browserInfo = await deviceInfo.webBrowserInfo;
    String? browserPlat = browserInfo!.platform;
    List<String?> brow = browserInfo!.userAgent.split(' ');
    String? brow1 = brow[brow.length - 1]!.replaceAll(RegExp(r'[0-9\/\.]'), '');
    String? brow2 = brow[brow.length - 2]!.replaceAll(RegExp(r'[0-9\/\.]'), '');
    String? brow3 = brow[brow.length - 3]!.replaceAll(RegExp(r'[0-9\/\.]'), '');
    String? browser;
    if (brow3.contains(RegExp(r'[\(\)]'))) {
      if (brow2.contains('Version')) {
        if (brow1.contains('Safari')) {
          browser = 'Safari';
          setState(() {
            browserIcon = Iconsdata.safari;
          });
        }
      } else if (brow2.contains('Chrome')) {
        if (brow1.contains('Safari')) {
          browser = 'Chrome';
          setState(() {
            browserIcon = Iconsdata.chrome;
          });
        }
      } else if (brow2.contains('Gecko')) {
        if (brow1.contains('Firefox')) {
          browser = 'Firefox';
          setState(() {
            browserIcon = Iconsdata.firefox;
          });
        }
      }
    } else if (brow3.contains('Chrome')) {
      if (brow2.contains('Safari')) {
        if (brow1.contains('Edg')) {
          browser = 'Edge';
          setState(() {
            browserIcon = Iconsdata.edge;
          });
        } else if (brow1.contains('OPR')) {
          browser = 'Opera';
          setState(() {
            browserIcon = Iconsdata.opera;
          });
        }
      }
    }
    if (browserPlat.toLowerCase() == 'win32') {
      return PlatformInfo(os: 'Windows', browser: browser!);
    } else if (browserPlat.toLowerCase() == 'macintel') {
      return PlatformInfo(os: 'Macos', browser: browser!);
    } else {
      return PlatformInfo(os: 'Linux', browser: browser!);
    }
  }

  Future<void> updateDB(GoogleSignInProvider provider) async {
    fireServer.userDataColRef
        .doc(uuid)
        .snapshots()
        .listen((DocumentSnapshot event) async {
      if (fireServer.mAuth.currentUser != null) {
        String? area = await locationInfo;
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
                  'location': area,
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
                              'Version : 2.5.5-alpha ',
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
                              onPressed: _openGitLink,
                            )
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
