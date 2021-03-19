import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passman/UI/desktop/desktop.dart';
import 'package:passman/UI/google_loggedin.dart';
import 'package:passman/UI/mobile/mobile.dart';
import 'package:passman/UI/web/web.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StateCheck extends StatefulWidget {
  @override
  _StateCheckState createState() => _StateCheckState();
}

class _StateCheckState extends State<StateCheck> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ChangeNotifierProvider<GoogleSignInProvider>(
          create: (BuildContext context) => GoogleSignInProvider(),
          child: StreamBuilder<dynamic>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              GoogleSignInProvider provider =
                  Provider.of<GoogleSignInProvider>(context);
              if (provider.isSigningIn) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  return const GoogleLoggedInScreen();
                } else {
                  if (defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS) {
                    return const Mobile();
                  } else if (kIsWeb) {
                    return const Web();
                  } else {
                    return const Desktop();
                  }
                }
              }
            },
          ),
        ),
      );
}
