import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/user_data.dart';

class WebLoggedinQRScreen extends StatefulWidget {
  @override
  _WebLoggedinQRScreenState createState() => _WebLoggedinQRScreenState();
}

class _WebLoggedinQRScreenState extends State<WebLoggedinQRScreen> {
  String? uuid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: StreamBuilder<DocumentSnapshot?>(
              stream: userDataColRef.doc(uuid).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot?> snapshot) {
                if (snapshot.hasData) {
                  UserData userData = UserData.fromDocument(snapshot.data!);
                  return Stack(
                    children: <Widget>[
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Lottie.asset(
                              LottieFiles.earth,
                              height: 20 * SizeConfig.widthMultiplier,
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
