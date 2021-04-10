import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/Components/theme_color.dart';
import 'package:passman/UI/desktop/desktop.dart';
import 'package:passman/UI/google_loggedin.dart';
import 'package:passman/UI/mobile/mobile.dart';
import 'package:passman/UI/mobile/passman_auth/en_de_code_screens/decode_screen.dart';
import 'package:passman/UI/mobile/passman_auth/en_de_code_screens/encode_screen.dart';
import 'package:passman/UI/mobile/passman_auth/passman_auth_screens/login.dart';
import 'package:passman/UI/mobile/passman_auth/passman_auth_screens/signup.dart';
import 'package:passman/UI/mobile/passman_auth/qr_screen/qrscan.dart';
import 'package:passman/UI/web/not_found.dart';
import 'package:passman/UI/web/web.dart';
import 'package:passman/services/state_check.dart';
import 'package:passman/splash_screen.dart';


GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? page;
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
              initialRoute: PageRoutes.routeHome,
              routes: <String, WidgetBuilder>{
                PageRoutes.routeHome: (BuildContext context) =>
                    const SplashScreen(),
                PageRoutes.routeState: (BuildContext context) =>
                    const StateCheck(),
                PageRoutes.routeMobile: (BuildContext context) =>
                    const Mobile(),
                PageRoutes.routeGoogleLoggedin: (BuildContext context) =>
                    const GoogleLoggedInScreen(),
                PageRoutes.routePassmanLogin: (BuildContext context) =>
                    const PassmanLogin(),
                PageRoutes.routePassmanEncodingScreen: (BuildContext context) =>
                    EncodingResultScreen(),
                PageRoutes.routePassmanDecodingScreen: (BuildContext context) =>
                    DecodingResultScreen(
                      ModalRoute.of(context)!.settings.arguments,
                    ),
                PageRoutes.routePassmanSignup: (BuildContext context) =>
                    const PassmanSignup(),
                PageRoutes.routeQRScan: (BuildContext context) =>
                    const QRScan(),
                PageRoutes.routeDesktop: (BuildContext context) =>
                    const Desktop(),
                PageRoutes.routeWeb: (BuildContext context) => const Web(),
                PageRoutes.routeNotFound: (BuildContext context) =>
                    NotFoundScreen(),
              },
              onUnknownRoute: (RouteSettings settings) =>
                  MaterialPageRoute<void>(
                builder: (BuildContext context) => NotFoundScreen(),
              ),
              onGenerateRoute: (RouteSettings settings) {
                switch (settings.name) {
                  case PageRoutes.routeHome:
                    page = const SplashScreen();
                    return;
                  case PageRoutes.routeState:
                    page = const StateCheck();
                    return;
                  case PageRoutes.routeGoogleLoggedin:
                    page = const GoogleLoggedInScreen();
                    return;
                  case PageRoutes.routePassmanLogin:
                    page = const PassmanLogin();
                    return;
                  case PageRoutes.routePassmanSignup:
                    page = const PassmanSignup();
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
                    page = const QRScan();
                    return;
                  case PageRoutes.routeDesktop:
                    page = const Desktop();
                    return;
                  case PageRoutes.routeMobile:
                    page = const Mobile();
                    return;
                  case PageRoutes.routeWeb:
                    page = const Web();
                    return;
                  default:
                    return null;
                }
              },
            );
          },
        ),
      );
}
