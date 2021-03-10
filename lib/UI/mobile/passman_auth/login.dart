import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:passman/Components/markers.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/points.dart';

class PassmanLogin extends StatefulWidget {
  const PassmanLogin({Key key}) : super(key: key);
  @override
  _PassmanLoginState createState() => _PassmanLoginState();
}

class _PassmanLoginState extends State<PassmanLogin> {
  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  List<Points> password = <Points>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onPanDown: (DragDownDetails details) {
                      final double clickX = details.localPosition.dx.toDouble();
                      final double clickY = details.localPosition.dy.toDouble();
                      password.add(
                        Points(
                          clickX.toDouble(),
                          clickY.toDouble(),
                        ),
                      );
                      setState(() {
                        password.length;
                      });
                      if (password.length >= 3) {
                        loggerNoStack.d('length is ${password.length}');
                      }
                      loggerNoStack.i('$clickX , $clickY');
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: SizeConfig.widthMultiplier * 90,
                          width: SizeConfig.widthMultiplier * 90,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color: Colors.blue[400],
                            ),
                            borderRadius: BorderRadius.circular(7),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: const Image(
                                image: AssetImage(
                                    'assets/images/img_placeholder.png'),
                              ).image,
                            ),
                          ),
                        ),
                        for (Points pass in password)
                          Marker(
                            dx: pass.x,
                            dy: pass.y,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5 * SizeConfig.heightMultiplier,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      password.length >= 1
                          ? IconButton(
                              tooltip: 'Undo',
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.blue[400],
                              ),
                              onPressed: () {
                                password.removeLast();
                                setState(() {
                                  password.length;
                                });
                                if (password.length >= 3) {
                                  loggerNoStack
                                      .d('length is ${password.length}');
                                }
                              },
                            )
                          : const SizedBox(
                              width: 49,
                              height: 49,
                            ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Submit',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w900,
                            fontSize: 3 * SizeConfig.textMultiplier,
                            color: Colors.blue[400],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 49,
                        height: 49,
                      ),
                    ],
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
