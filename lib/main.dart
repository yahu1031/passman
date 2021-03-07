import 'package:flutter/material.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/Components/theme_color.dart';
import 'package:passman/UI/desktop/desktop.dart';
import 'package:passman/UI/mobile/mobile.dart';
import 'package:passman/UI/web/web.dart';
import 'package:passman/services/encryption.dart';
import 'package:passman/services/random.dart';
import 'package:passman/splash_screen.dart';
import 'package:provider/single_child_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            SizeConfig().init(constraints, orientation);
            return MultiProvider(
              providers: <SingleChildWidget>[
                ChangeNotifierProvider<RandomNumberGenerator>.value(
                  value: RandomNumberGenerator(),
                ),
                ChangeNotifierProvider<Encryption>.value(
                  value: Encryption(),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(primary: primaryBlack),
                  ),
                ),
                builder: (BuildContext context, Widget widget) =>
                    ResponsiveWrapper.builder(
                  ClampingScrollWrapper.builder(context, widget),
                  defaultScale: true,
                  defaultName: MOBILE,
                  breakpoints: const <ResponsiveBreakpoint>[
                    ResponsiveBreakpoint.resize(450, name: MOBILE),
                    ResponsiveBreakpoint.autoScale(800, name: TABLET),
                    ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                    ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                    ResponsiveBreakpoint.autoScale(2460, name: '4K'),
                  ],
                ),
                initialRoute: '/',
                routes: <String, WidgetBuilder>{
                  '/': (BuildContext context) => const SplashScreen(),
                  '/mobile': (BuildContext context) => const Mobile(),
                  '/desktop': (BuildContext context) => const Desktop(),
                  '/web': (BuildContext context) => const Web(),
                },
              ),
            );
          },
        );
      },
    );
  }
}
