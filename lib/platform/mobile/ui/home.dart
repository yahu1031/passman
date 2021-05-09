import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<DocumentSnapshot>? _listenToDB;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _listenToDB?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot?>(
            stream: fireServer.userDataColRef
                .doc(fireServer.mAuth.currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot?> snapshot) {
              if (snapshot.data == null) {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              } else if (!snapshot.data!.exists) {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              } else if (snapshot.hasError) {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              } else if (!snapshot.hasData) {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              } else if (snapshot.hasData) {
                return ZStack(
                  <Widget>[
                    VStack(
                      <Widget>[
                        '''
Last web loggedin token:\n${snapshot.data!.data()!['token']}'''
                            .selectableText
                            .center
                            .bold
                            .makeCentered(),
                        '''
Last web loggedin time:\n${DateFormat.MMMMEEEEd().add_Hm().format(snapshot.data!.data()!['logged_in_time'].toDate()).toString()}'''
                            .selectableText
                            .center
                            .bold
                            .makeCentered(),
                      ],
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                      axisSize: MainAxisSize.max,
                    ),
                    VStack(
                      <Widget>[
                        Hero(
                          tag: 'dp',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                fireServer.mAuth.currentUser!.photoURL!),
                          ),
                        ),
                        'Ola ${fireServer.mAuth.currentUser!.displayName}'
                            .text
                            .bold
                            .xl2
                            .fontFamily('LexendDeca')
                            .make(),
                      ],
                    ).positioned(top: 20, left: 20),
                    snapshot.data!.data()!['img'] != 'No records'
                        ? IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            icon: const Icon(Iconsdata.device),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                PageRoutes.routeQRScan,
                              );
                            },
                          ).positioned(top: 20, right: 10)
                        : const SizedBox.shrink(),
                    VStack(
                      <Widget>[
                        snapshot.data!.data()!['img'] != 'No records'
                            ? TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) =>
                                          Colors.transparent),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          AppColors.appMainColor),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                  ),
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  PageRoutes.routePassmanLogin,
                                ),
                                child: VxBox(
                                  child: 'Login'
                                      .text
                                      .white
                                      .lg
                                      .bold
                                      .make()
                                      .centered(),
                                ).make().h(25).w(270),
                              ).centered().px2()
                            : const SizedBox.shrink(),
                        VxBox().make().h1(context),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (Set<MaterialState> states) =>
                                    Colors.transparent),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.appMainColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          onPressed: () async => Navigator.pushNamed(
                            context,
                            PageRoutes.routePassmanSignup,
                          ),
                          child: VxBox(
                            child: snapshot.data!.data()!['img'] != 'No records'
                                ? 'Change Image'
                                    .text
                                    .white
                                    .bold
                                    .lg
                                    .make()
                                    .centered()
                                : 'Signup'.text.white.bold.lg.make().centered(),
                          ).make().h(25).w(270),
                        ).centered().px2(),
                      ],
                    ).positioned(bottom: 10, right: 0, left: 0),
                  ],
                );
              }
              return const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                strokeWidth: 3,
              ).centered();
            }),
      ),
    );
  }
}
