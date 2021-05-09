import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passman/platform/mobile/components/data_card.dart';
import 'package:passman/platform/web/model/device_info.dart';
import 'package:passman/platform/web/services/internet_services.dart';
import 'package:passman/platform/web/ui/web.dart';
import 'package:passman/services/auth.dart';
import 'package:passman/services/crypto/decryption.dart';
import 'package:passman/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String uuid = fireServer.mAuth.currentUser!.uid;
  FetchLocation fetchLocation = FetchLocation();
  bool isDataFetched = false;
  StreamSubscription<DocumentSnapshot>? _dbStream;

  static Future<void> copy(String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      return;
    } else {
      throw ('Please enter a string');
    }
  }

  Future<void> updateDB(GoogleSignInProvider provider) async {
    _dbStream = fireServer.userDataColRef
        .doc(uuid)
        .snapshots()
        .listen((DocumentSnapshot event) async {
      if (fireServer.mAuth.currentUser != null) {
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
              }).catchError((dynamic onError) async {
                if (mounted) {
                  setState(() {
                    isDataFetched = false;
                  });
                }
                await provider.logout();
                throw 'Update catch error: ${onError.toString()}';
              }).onError((Object? error, StackTrace stackTrace) async {
                if (mounted) {
                  setState(() {
                    isDataFetched = false;
                  });
                }
                await provider.logout();
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
          } else if (event.data()!['web_login'] == true) {
            setState(() {
              isDataFetched = true;
            });
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
  void dispose() {
    _dbStream?.cancel();
    super.dispose();
  }

  String? area1;
  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Tooltip(
          message: fireServer.mAuth.currentUser!.displayName!.toUpperCase(),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              fireServer.mAuth.currentUser!.photoURL!,
            ),
            foregroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            foregroundImage: NetworkImage(
              fireServer.mAuth.currentUser!.photoURL!,
            ),
            minRadius: 15,
          ).p12(),
        ),
        actions: <Widget>[
          IconButton(
            splashRadius: 0.001,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            tooltip: '''
Log out as ${fireServer.mAuth.currentUser!.displayName!.toUpperCase()}.''',
            icon: const Icon(
              Iconsdata.logout,
              color: Colors.black,
            ),
            onPressed: () async {
              await provider.logout();
              await fireServer.userDataColRef.doc(uuid).update(
                <String, dynamic>{
                  'web_login': false,
                  'platform': 'No records',
                  'browser': 'No records',
                  'location': 'No records',
                  'ip': 'No records'
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: fireServer.userDataColRef.doc(uuid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            return ZStack(
              <Widget>[
                StreamBuilder<QuerySnapshot?>(
                  stream: FirebaseFirestore.instance
                      .collection('UserData/$uuid/Accounts')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot?> snapshots) {
                    if (snapshots.hasData) {
                      if (snapshots.data!.docs.isEmpty) {
                        return 'No data to fetch'
                            .text
                            .black
                            .medium
                            .fontFamily('LexendDeca')
                            .semiBold
                            .center
                            .make()
                            .centered();
                      } else {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshots.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot documentSnapshot =
                                snapshots.data!.docs[index];
                            return DataCard(
                              documentSnapshot.id.toString(),
                              copyPressed: () async {
                                await copy(
                                  decryption.uPassDecryption(
                                    documentSnapshot['password'],
                                  ),
                                ).whenComplete(() async {
                                  log('Copied to clipboard');
                                });
                              },
                            );
                          },
                        );
                      }
                    } else if (!snapshots.hasData) {
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.appMainColor),
                        strokeWidth: 3,
                      ).centered();
                    } else if (snapshots.hasError) {
                      return 'Sorry there was some error while fetching data'
                          .text
                          .black
                          .lg
                          .fontFamily('LexendDeca')
                          .semiBold
                          .center
                          .make()
                          .centered();
                    }
                    return const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                      strokeWidth: 3,
                    );
                  },
                ),
              ],
            );
          } else if (!snapshot.hasData) {
            return const WebHomeScreen();
          } else {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
              strokeWidth: 3,
            ).centered();
          }
        },
      ),
    );
  }
}
