import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
}

FirebaseAuth mAuth = FirebaseAuth.instance;

CollectionReference userDataColRef =
    FirebaseFirestore.instance.collection('UserData');

CollectionReference qrColRef =
    FirebaseFirestore.instance.collection('TempUserID');

Reference storageRef =
    FirebaseStorage.instance.ref();

int binSize = 20;
