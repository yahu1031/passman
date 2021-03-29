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
  late String mUsertoken;

  // Get uid
  Future<String> getCurrentUid() async => _firebaseAuth.currentUser!.uid;

  // Get current Users
  String getCurrentUser() => _firebaseAuth.currentUser!.displayName.toString();

  // Get current User id Token
  Future<String> getUserToken() async {
    User? tokenResult = await _firebaseAuth.currentUser;
    String idToken = await tokenResult!.getIdToken();
    return await idToken.toString();
  }

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

  Future<void> tokenLogin() async {
    try {
      User? tokenResult = await _firebaseAuth.currentUser;
      String? idToken = await tokenResult?.getIdToken();
      String mToken = await idToken.toString();
      loggerNoStack.i(idToken);
      await _firebaseAuth.signInWithCustomToken(mToken).then(
        (UserCredential value) {
          loggerNoStack.i(value);
        },
      ).onError((dynamic error, StackTrace stackTrace) {
        loggerNoStack.i(error.toString());
      });
    } catch (e) {
      loggerNoStack.e(e.toString());
    }
  }

  Future<void> login() async {
    isSigningIn = true;
    GoogleSignInAccount? user = await googleSignIn
        .signIn()
        .onError((dynamic error, StackTrace stackTrace) {
      loggerNoStack.e(error.toString());
    }).catchError((dynamic onError) {
      loggerNoStack.e(onError.toString());
    });
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
        loggerNoStack.e(error.toString());
      }).catchError((dynamic onError) {
        loggerNoStack.e(onError.toString());
      });

      isSigningIn = false;
    }
  }

  Future<void> signinWithToken() async {
    await FirebaseAuth.instance.signInWithCustomToken('''
eyJhbGciOiJSUzI1NiIsImtpZCI6IjRlMDBlOGZlNWYyYzg4Y2YwYzcwNDRmMzA3ZjdlNzM5Nzg4ZTRmMWUiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoic2lhIHN1bm50IiwicGljdHVyZSI6Imh0dHBzOi8vbGg1Lmdvb2dsZXVzZXJjb250ZW50LmNvbS8tY0gwUWg5Wi11eFUvQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQU1adXVjbVZmNmE0OVpYUVVhRlNoaG9tZndTbFZBWUtLdy9zOTYtYy9waG90by5qcGciLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vcGFzc3dvcmQtbWFnbmFnZXIiLCJhdWQiOiJwYXNzd29yZC1tYWduYWdlciIsImF1dGhfdGltZSI6MTYxNjQ4ODQ0MiwidXNlcl9pZCI6IjVxNU1XblpqMGdQQjZHQ2QwTWJSS1dmdmhrdTIiLCJzdWIiOiI1cTVNV25aajBnUEI2R0NkME1iUktXZnZoa3UyIiwiaWF0IjoxNjE2NTA0NTA5LCJleHAiOjE2MTY1MDgxMDksImVtYWlsIjoic2lhc3VubnQzMjRAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMTU0OTc4Mjg3MjI4Nzk4MTk1NjciXSwiZW1haWwiOlsic2lhc3VubnQzMjRAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.li7L1u72gVub767A3Z9k-iccAxHrTjQ8R2ADbEeWkX67uEgkr-vKRzSJmoEzxPjnLRenPREPmtM29LbFiY2XWbpfM8BrbVliE9MLDAtYrowi9RfLI8Z6Q6nPnVxA1PSIpP_MApGKnuPgiwY9wjG1In9heMNcPqJ9oFGbO0uMsyQGdmfcp_dv2d_NHEpcilfIAxBwRu8wF2L0DAdz01uxbaahTUbP8yszom5bTYIjgCkBqsioLnnYmIVUlEkV-3ibA23lx3ePD9fp6F4N9L9Q8v_KYw5y9isKioqfS_-2o1ptsGxh9SqpdMn8NAk8TKw5PBdYTYxoWkMKyAKZloctFg''').then(
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
