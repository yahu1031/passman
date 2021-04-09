import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class PageRoutes {
  static const String routeHome = '/';
  static const String routeState = '/state';
  static const String routeGoogleLoggedin = '/googleloggedin';
  static const String routePassmanLogin = '/passmanlogin';
  static const String routePassmanSignup = '/passmanSignup';
  static const String routePassmanEncodingScreen = '/encodeScreen';
  static const String routePassmanDecodingScreen = '/decodeScreen';
  static const String routeQRScan = '/qrscan';
  static const String routeDesktop = '/desktop';
  static const String routeWeb = '/web';
  static const String routeMobile = '/mobile';
  static const String routeNotFound = '/you_are_lost';
}

class LottieFiles {
  static const String fingerprint = 'assets/lottie/fingerprint.json';
  static const String done = 'assets/lottie/done.json';
  static const String earth = 'assets/lottie/earth.json';
  static const String google = 'assets/lottie/google.json';
  static const String network = 'assets/lottie/network.json';
  static const String sorry = 'assets/lottie/sorry.json';
}

class FireServer {
  FirebaseAuth mAuth = FirebaseAuth.instance;

  CollectionReference userDataColRef =
      FirebaseFirestore.instance.collection('UserData');

  CollectionReference qrColRef =
      FirebaseFirestore.instance.collection('TempUserID');

  Reference storageRef = FirebaseStorage.instance.ref();
}

FireServer fireServer = FireServer();

const int binSize = 20;

class Iconsdata {
  static const IconData x = IconData(0xeb55, fontFamily: 'IconsFont');
  static const IconData flashOff = IconData(0xea50, fontFamily: 'IconsFont');
  static const IconData flashOn = IconData(0xea51, fontFamily: 'IconsFont');
  static const IconData copy = IconData(0xea7a, fontFamily: 'IconsFont');
  static const IconData time = IconData(0xea70, fontFamily: 'IconsFont');
  static const IconData ip = IconData(0xed5e, fontFamily: 'IconsFont');
  static const IconData browser = IconData(0xebb7, fontFamily: 'IconsFont');
  static const IconData location = IconData(0xeae7, fontFamily: 'IconsFont');
  static const IconData testtube = IconData(0xeb3a, fontFamily: 'IconsFont');
  static const IconData device = IconData(0xeb87, fontFamily: 'IconsFont');
  static const IconData logout = IconData(0xeba8, fontFamily: 'IconsFont');
  static const IconData windows = IconData(0xecd8, fontFamily: 'IconsFont');
  static const IconData mac = IconData(0xec17, fontFamily: 'IconsFont');
  static const IconData linux = IconData(0xea45, fontFamily: 'IconsFont');
  static const IconData plus = IconData(0xeb0b, fontFamily: 'IconsFont');
  static const IconData edge = IconData(0xecfc, fontFamily: 'IconsFont');
  static const IconData chrome = IconData(0xec18, fontFamily: 'IconsFont');
  static const IconData firefox = IconData(0xecfd, fontFamily: 'IconsFont');
  static const IconData safari = IconData(0xec23, fontFamily: 'IconsFont');
  static const IconData opera = IconData(0xec21, fontFamily: 'IconsFont');
  static const IconData github = IconData(0xec1c, fontFamily: 'IconsFont');
  static const IconData refresh = IconData(0xeb13, fontFamily: 'IconsFont');
}
