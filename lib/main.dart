import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:passman/platform/mobile/ui/user_data/user_data_screen.dart';
import 'package:passman/services/state_check.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:passman/platform/mobile/mobile.dart';
import 'package:passman/services/auth.dart';
import 'package:passman/platform/mobile/ui/en_de_coding/decoding_screen.dart';
import 'package:passman/platform/mobile/ui/en_de_coding/encoding_screen.dart';
import 'package:passman/platform/mobile/ui/passman_auth/login.dart';
import 'package:passman/platform/mobile/ui/passman_auth/signup.dart';
import 'package:passman/platform/mobile/ui/qr_scan.dart';
import 'package:passman/platform/web/services/token_gen.dart';
import 'package:passman/platform/web/ui/not_found.dart';
import 'package:passman/platform/web/ui/web.dart';
import 'package:passman/services/crypto/encryption.dart';
import 'package:passman/splash_screen.dart';
import 'package:passman/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<TokenGenerator>(create: (_) => TokenGenerator()),
        ChangeNotifierProvider<Encryption>(create: (_) => Encryption()),
        ChangeNotifierProvider<GoogleSignInProvider>(
            create: (_) => GoogleSignInProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? page;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'passman Manager',
      initialRoute: PageRoutes.routeHome,
      routes: <String, WidgetBuilder>{
        PageRoutes.routeHome: (BuildContext context) => const SplashScreen(),
        PageRoutes.routeState: (BuildContext context) => StateCheck(),
        PageRoutes.routeMobile: (BuildContext context) => Mobile(),
        PageRoutes.routePassmanLogin: (BuildContext context) => PassmanLogin(),
        PageRoutes.routePassmanSignup: (BuildContext context) =>
            PassmanSignup(),
        PageRoutes.routeQRScan: (BuildContext context) => QrScan(),
        PageRoutes.routePassmanEncodingScreen: (BuildContext context) =>
            EncodingResultScreen(),
        PageRoutes.routePassmanDecodingScreen: (BuildContext context) =>
            DecodingResultScreen(
              ModalRoute.of(context)!.settings.arguments,
            ),
        PageRoutes.routeUserDataScreen: (BuildContext context) =>
            UserDataScreen(),
        PageRoutes.routeWeb: (BuildContext context) => const WebHomeScreen(),
        PageRoutes.routeNotFound: (BuildContext context) => NotFoundScreen(),
      },
      onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<void>(
        builder: (BuildContext context) => NotFoundScreen(),
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case PageRoutes.routeHome:
            page = const SplashScreen();
            return;
          case PageRoutes.routeState:
            page = StateCheck();
            return;
          case PageRoutes.routePassmanLogin:
            page = PassmanLogin();
            return;
          case PageRoutes.routePassmanSignup:
            page = PassmanSignup();
            return;
          case PageRoutes.routePassmanEncodingScreen:
            page = EncodingResultScreen();
            return;
          case PageRoutes.routePassmanDecodingScreen:
            page = DecodingResultScreen(
              ModalRoute.of(context)!.settings.arguments,
            );
            return;
          case PageRoutes.routeQRScan:
            page = QrScan();
            return;
          case PageRoutes.routeUserDataScreen:
            page = UserDataScreen();
            return;
          case PageRoutes.routeMobile:
            page = Mobile();
            return;
          case PageRoutes.routeWeb:
            page = const WebHomeScreen();
            return;
          default:
            return null;
        }
      },
    );
  }
}
