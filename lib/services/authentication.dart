import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleSignInProvider extends ChangeNotifier {
  GoogleSignInProvider() {
    _isSigningIn = false;
  }
  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isSigningIn;

  // Get uid
  Future<String> getCurrentUid() async {
    return _firebaseAuth.currentUser.uid;
  }

  // Get current Users
  String getCurrentUser() {
    return _firebaseAuth.currentUser.displayName;
  }

// Get current Users
  String getCurrentUserEmail() {
    return _firebaseAuth.currentUser.email;
  }

  // Get image url
  Object getUserImage() {
    if (_firebaseAuth.currentUser.photoURL != null) {
      return NetworkImage(
        _firebaseAuth.currentUser.photoURL,
      );
    } else {
      return const Icon(Icons.account_circle_outlined);
    }
  }

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future<void> login() async {
    isSigningIn = true;
    final GoogleSignInAccount user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final GoogleSignInAuthentication googleAuth = await user.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential).then(
        (UserCredential value) {
          loggerNoStack.i(value);
        },
      ).onError((dynamic error, StackTrace stackTrace) {
        loggerNoStack.i(error.toString());
      });

      isSigningIn = false;
    }
  }

  Future<void> logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
