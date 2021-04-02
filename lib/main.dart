import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/Components/theme_color.dart';
import 'package:passman/UI/desktop/desktop.dart';
import 'package:passman/UI/google_loggedin.dart';
import 'package:passman/UI/mobile/mobile.dart';
import 'package:passman/UI/mobile/passman_auth/login.dart';
import 'package:passman/UI/mobile/passman_auth/signup.dart';
import 'package:passman/UI/mobile/qrscan.dart';
import 'package:passman/UI/web/not_found.dart';
import 'package:passman/UI/web/web.dart';
import 'package:passman/services/state_check.dart';
import 'package:passman/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            SizeConfig().init(constraints, orientation);
            return MaterialApp(
              title: 'Password Manager',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: Colors.black,
                primarySwatch: primaryBlack,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: primaryBlack,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: primaryBlack,
                    backgroundColor: Colors.white,
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: primaryBlack,
                  ),
                ),
              ),
              initialRoute: '/',
              routes: <String, WidgetBuilder>{
                '/': (BuildContext context) => const SplashScreen(),
                '/state': (BuildContext context) => const StateCheck(),
                '/mobile': (BuildContext context) => const Mobile(),
                '/googleloggedin': (BuildContext context) =>
                    const GoogleLoggedInScreen(),
                '/passmanlogin': (BuildContext context) => const PassmanLogin(),
                '/passmansignup': (BuildContext context) =>
                    const PassmanSignup(),
                '/qrscan': (BuildContext context) => const QRScan(),
                '/desktop': (BuildContext context) => const Desktop(),
                '/web': (BuildContext context) => const Web(),
                NotFoundScreen.id: (BuildContext context) => NotFoundScreen(),
              },
              onUnknownRoute: (RouteSettings settings) =>
                  MaterialPageRoute<void>(
                builder: (BuildContext context) => NotFoundScreen(),
              ),
            );
          },
        ),
      );
}
