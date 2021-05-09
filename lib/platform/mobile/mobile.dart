import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:passman/platform/mobile/google_login.dart';
import 'package:passman/services/auth.dart';
import 'package:passman/platform/mobile/ui/home.dart';
import 'package:passman/utils/constants.dart';

class Mobile extends StatefulWidget {
  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  Future<void> checkUserDB() async {
    String? uuid = fireServer.mAuth.currentUser!.uid;
    String? name = fireServer.mAuth.currentUser!.displayName;
    DocumentReference userDataDocRef =
        FirebaseFirestore.instance.collection('UserData').doc(uuid);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<GoogleSignInProvider>(
        create: (BuildContext context) => GoogleSignInProvider(),
        child: StreamBuilder<User?>(
          stream: fireServer.mAuth.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            GoogleSignInProvider provider =
                Provider.of<GoogleSignInProvider>(context);
            if (snapshot.connectionState == ConnectionState.active) {
              if (provider.isSigningIn) {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              } else {
                if (snapshot.hasData) {
                  checkUserDB();
                  return HomeScreen();
                } else {
                  return GoogleLogin();
                }
              }
            } else {
              return const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                strokeWidth: 3,
              ).centered();
            }
          },
        ),
      ),
    );
  }
}
