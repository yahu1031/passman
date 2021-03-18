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
  bool _isSigningIn = false;

  // Get uid
  Future<String> getCurrentUid() async => _firebaseAuth.currentUser!.uid;

  // Get current Users
  String getCurrentUser() => _firebaseAuth.currentUser!.displayName.toString();

  // Get current User id Token
  Future<String> getUserToken() async =>
      _firebaseAuth.currentUser!.getIdToken();

// Get current Users
  String getCurrentUserEmail() => _firebaseAuth.currentUser!.email.toString();

  // Get image url
  Object getUserImage() {
    if (_firebaseAuth.currentUser!.photoURL != null) {
      return NetworkImage(
        _firebaseAuth.currentUser!.photoURL.toString(),
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
    GoogleSignInAccount? user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      GoogleSignInAuthentication googleAuth = await user.authentication;
      OAuthCredential credential = GoogleAuthProvider.credential(
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

  Future<void> signinWithToken() async {
    await FirebaseAuth.instance.signInWithCustomToken('''
eyJhbGciOiJSUzI1NiIsImtpZCI6IjRlMDBlOGZlNWYyYzg4Y2YwYzcwNDRmMzA3ZjdlNzM5Nzg4ZTRmMWUiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiTWlubnUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2pUVkFKd0NqS3JoNndlUFVGTVF5azdXbFV2S2Y3NWtTT3dZSUNucGRjPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3Bhc3N3b3JkLW1hZ25hZ2VyIiwiYXVkIjoicGFzc3dvcmQtbWFnbmFnZXIiLCJhdXRoX3RpbWUiOjE2MTUyOTQ4MTIsInVzZXJfaWQiOiI2RG0xZUJNd0hBZnhzdFFPcFJZa1NZZGMzWXkxIiwic3ViIjoiNkRtMWVCTXdIQWZ4c3RRT3BSWWtTWWRjM1l5MSIsImlhdCI6MTYxNTk3NDgzOCwiZXhwIjoxNjE1OTc4NDM4LCJlbWFpbCI6IjAxMTExMTIzMzRtYUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExNjA5MTgwODUxMjc4ODg1NzYxOSJdLCJlbWFpbCI6WyIwMTExMTEyMzM0bWFAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.Zw86l3EvwuU-B-lqlrfF4OcvkbjgxpEZjJQXx-T_O2OkIk8I7RDwxUpdWoJqwVeCodg_MmrKvOPpaId_cFgTMCVe2x2YvzV6wN69aQJTritipPSKZGPODwDxnksz3Bv5JgaUvg7BaST2p5eBIbGACnnipQpLBOoKa-1B4UQC19-KllRF-ARMHPt9AmjG_7BQgoOZzy''').then(
      (UserCredential value) {
        loggerNoStack.i(value);
      },
    ).onError((dynamic error, StackTrace stackTrace) {
      loggerNoStack.i(error.toString());
    });
  }

  Future<void> logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
