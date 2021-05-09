import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passman/platform/mobile/google_login.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:passman/platform/mobile/ui/home.dart';
import 'package:passman/platform/web/ui/user_screen.dart';
import 'package:passman/platform/web/ui/web.dart';
import 'package:passman/services/auth.dart';
import 'package:passman/utils/constants.dart';

class StateCheck extends StatelessWidget {
  Future<void> checkUserDB() async {
    String? uuid = fireServer.mAuth.currentUser!.uid;
    String? name = fireServer.mAuth.currentUser!.displayName;
    DocumentReference userDataDocRef = fireServer.userDataColRef.doc(uuid);
    try {
      DocumentSnapshot checkData = await userDataDocRef.get();
      if (checkData.exists) {
        if (checkData.data()!['web_login'] == false) {
          await userDataDocRef.update(<String, dynamic>{
            'name': name,
            'web_login': false,
            'platform': 'No records',
            'browser': 'No records',
            'ip': 'No records',
            'location': 'No records',
          }).onError((dynamic firestoreError, StackTrace stackTrace) {
            throw firestoreError.toString();
          }).catchError((dynamic onFirestoreError) {
            throw onFirestoreError.toString();
          });
        }
      } else {
        await userDataDocRef.set(<String, dynamic>{
          'name': name,
          'web_login': false,
          'img': 'No records',
          'platform': 'No records',
          'browser': 'No records',
          'logged_in_time': 'No records',
          'location': 'No records',
          'ip': 'No records',
          'token': 'No token yet'
        }).onError((dynamic firestoreError, StackTrace stackTrace) {
          throw firestoreError.toString();
        }).catchError((dynamic onFirestoreError) {
          throw onFirestoreError.toString();
        });
      }
    } catch (err) {
      throw err.toString();
    }
  }

  Future<void> userHomeWidget(
      String uuid, GoogleSignInProvider provider) async {
    DocumentReference userDataDocRef = fireServer.userDataColRef.doc(uuid);
    try {
      DocumentSnapshot checkData = await userDataDocRef.get();
      if (checkData.exists) {
        if (checkData.data()!['web_login'] == true) {
          DateTime time = checkData.data()!['logged_in_time'].toDate();
          log(DateTime.now().difference(time).inMinutes.toString());
          if (DateTime.now().difference(time).inMinutes >= 7) {
            try {
              await provider.logout().whenComplete(() async {
                await userDataDocRef.update(<String, dynamic>{
                  'web_login': false,
                  'platform': 'No records',
                  'browser': 'No records',
                  'ip': 'No records',
                  'location': 'No records',
                }).onError((dynamic firestoreError, StackTrace stackTrace) {
                  throw firestoreError.toString();
                }).catchError((dynamic onFirestoreError) {
                  throw onFirestoreError.toString();
                });
              });
            } catch (err) {
              throw err.toString();
            }
          }
        }
      }
    } catch (err) {
      throw err.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider = Provider.of<GoogleSignInProvider>(context);
    return Scaffold(
      body: ChangeNotifierProvider<GoogleSignInProvider>(
        create: (BuildContext context) => GoogleSignInProvider(),
        child: StreamBuilder<dynamic>(
          stream: fireServer.mAuth.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (provider.isSigningIn) {
              return const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                strokeWidth: 3,
              ).centered();
            } else {
              if (snapshot.hasData) {
                if (kIsWeb) {
                  log('User loggedin');
                  return UserScreen();
                } else {
                  checkUserDB();
                  return HomeScreen();
                }
              } else {
                if (kIsWeb) {
                  log('User not loggedin');
                  if (fireServer.mAuth.currentUser != null) {
                    userHomeWidget(fireServer.mAuth.currentUser!.uid, provider);
                    return UserScreen();
                  } else {
                    return const WebHomeScreen();
                  }
                } else {
                  return GoogleLogin();
                }
              }
            }
          },
        ),
      ),
    );
  }
}
