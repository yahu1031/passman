import 'package:device_info_plus/device_info_plus.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/services/internet_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';

class WebGoogleLoggedin extends StatefulWidget {
  @override
  _WebGoogleLoggedinState createState() => _WebGoogleLoggedinState();
}

class _WebGoogleLoggedinState extends State<WebGoogleLoggedin> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  List<String>? webPlatform;
  Map<String, dynamic> map = <String, dynamic>{};
  final String _url = 'https://github.com/yahu1031/passman';
  Future<void> _openGitLink() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  WebBrowserInfo? browserInfo;
  Future<String> platformInfo() async {
    browserInfo = await deviceInfo.webBrowserInfo;
    String? browserPlat = browserInfo!.platform;
    switch (browserPlat) {
      case 'win32':
        return 'Windows';
      default:
        return 'Unix';
    }
  }

  @override
  void initState() {
    super.initState();
    fireServer.userDataColRef
        .doc(uuid)
        .snapshots()
        .listen((DocumentSnapshot event) async {
      if (fireServer.mAuth.currentUser != null) {
        String? ipAddress = await FetchIP.getIP();
        String? loggedInPlatform = await platformInfo();
        if (event.exists) {
          if (event.data()!['ip'] == 'No records' ||
              event.data()!['logged_in_time'] == 'No records' ||
              event.data()!['platform'] == 'No records') {
            try {
              await fireServer.userDataColRef.doc(uuid).update(
                <String, dynamic>{
                  'web_login': true,
                  'platform': loggedInPlatform,
                  'ip': ipAddress,
                  'logged_in_time': Timestamp.now()
                },
              ).catchError((dynamic onError) {
                throw 'Update catch error: ${onError.toString()}';
              }).onError((Object? error, StackTrace stackTrace) {
                throw 'Update on error: ${error.toString()}';
              });
            } catch (err) {
              throw 'Update try catch error: ${err.toString()}';
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
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
                        'Version : 2.3.3-alpha.5 ',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
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
Log out as ${fireServer.mAuth.currentUser!.displayName.toString().toUpperCase()}.''',
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
                    'logged_in_time': 'No records',
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
              message: provider.getCurrentUser().toUpperCase(),
              child: CircleAvatar(
                backgroundImage: provider.getUserImage() as ImageProvider,
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                foregroundImage: provider.getUserImage() as ImageProvider,
                minRadius: 4 * SizeConfig.imageSizeMultiplier,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
