import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/login_details.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/user_data.dart';

class WebLoggedinQRScreen extends StatefulWidget {
  @override
  _WebLoggedinQRScreenState createState() => _WebLoggedinQRScreenState();
}

class _WebLoggedinQRScreenState extends State<WebLoggedinQRScreen> {
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  String? plat, browser;
  IconData? platformIcons, browserIcons;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: StreamBuilder<DocumentSnapshot?>(
              stream: fireServer.userDataColRef.doc(uuid).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot?> snapshot) {
                if (snapshot.hasData) {
                  UserData userData = UserData.fromDocument(snapshot.data!);
                  plat = userData.platform!;
                  browser = userData.platform!;
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
                  return Stack(
                    children: <Widget>[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Tooltip(
                                  message: plat!,
                                  child: Icon(
                                    platformIcons,
                                    color: Colors.black,
                                    size: 7 * SizeConfig.textMultiplier,
                                  ),
                                ),
                                Icon(
                                  Iconsdata.plus,
                                  color: Colors.black,
                                  size: 3 * SizeConfig.textMultiplier,
                                ),
                                Tooltip(
                                  message: browser!,
                                  child: Icon(
                                    browserIcons,
                                    color: Colors.black,
                                    size: 7 * SizeConfig.textMultiplier,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10 * SizeConfig.heightMultiplier,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.ltr,
                              children: <Widget>[
                                LoginDetails(
                                  userData: userData,
                                  icon: Iconsdata.ip,
                                  title: 'IP Address',
                                  content: userData.ip!,
                                ),
                                LoginDetails(
                                  userData: userData,
                                  icon: Iconsdata.location,
                                  title: 'Location',
                                  content: userData.location!,
                                ),
                                LoginDetails(
                                  userData: userData,
                                  icon: Iconsdata.time,
                                  title: 'Login Time',
                                  content: time
                                      .toString()
                                      .replaceAll(RegExp(r'[\[\]]'), ''),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_outlined,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              }),
        ),
      );
}
