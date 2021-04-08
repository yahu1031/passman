import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/user_data.dart';

class WebLoggedinQRScreen extends StatefulWidget {
  @override
  _WebLoggedinQRScreenState createState() => _WebLoggedinQRScreenState();
}

class _WebLoggedinQRScreenState extends State<WebLoggedinQRScreen> {
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  String? plat;
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
                                  message: 'Windows',
                                  child: Icon(
                                    plat!.contains('window')
                                        ? Iconsdata.windows
                                        : plat!.contains('Macintosh')
                                            ? Iconsdata.mac
                                            : Iconsdata.linux,
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
                                  message: 'Edge',
                                  child: Icon(
                                    Iconsdata.edge,
                                    color: Colors.black,
                                    size: 7 * SizeConfig.textMultiplier,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10 * SizeConfig.heightMultiplier,
                            ),
                            Text(
                              '''
IP address : ${userData.ip!}\nplatform : ${userData.platform!}\nTime: : ${userData.logged_in_time!.toDate()}''',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 2 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.bold,
                              ),
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
