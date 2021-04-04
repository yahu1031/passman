import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';

class WebGoogleLoggedin extends StatefulWidget {
  @override
  _WebGoogleLoggedinState createState() => _WebGoogleLoggedinState();
}

class _WebGoogleLoggedinState extends State<WebGoogleLoggedin> {
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoggedinal = false;
  final String _url = 'https://github.com/yahu1031/passman';
  Future<void> _openGitLink() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  @override
  void initState() {
    super.initState();
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('UserData').doc(uuid);
    docRef.snapshots().listen((DocumentSnapshot event) async {
      if (event.exists) {
        if (event.data()!['web_login'] == false) {
          await docRef.update(
            <String, dynamic>{
              'web_login': true,
            },
          );
        }
        ;
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
                    'assets/lottie/google.json',
                    height: 30 * SizeConfig.heightMultiplier,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: 'Version : 2.2.2-alpha ',
                          style: GoogleFonts.quicksand(
                            fontSize: 1 * SizeConfig.textMultiplier,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: '🧪',
                              style: GoogleFonts.notoSans(
                                fontSize: 1 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        splashRadius: 0.001,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(
                          const IconData(
                            0xec1c,
                            fontFamily: 'IconsFont',
                          ),
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
              tooltip: 'Log out as ${provider.getCurrentUser().toUpperCase()}.',
              icon: const Icon(TablerIcons.logout),
              onPressed: () {
                provider.logout().whenComplete(() => <void>{
                      FirebaseFirestore.instance
                          .collection('UserData')
                          .doc(uuid)
                          .update(
                        <String, dynamic>{
                          'web_login': false,
                        },
                      )
                    });
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
