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
        .onError((dynamic signinError, StackTrace stackTrace) {
      loggerNoStack.e(signinError.toString());
    }).catchError((dynamic onSigninError) {
      loggerNoStack.e(onSigninError.toString());
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

      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .catchError((dynamic onSigninCredsError) {
        loggerNoStack.e(onSigninCredsError.toString());
      });
      isSigningIn = false;
    }
  }

  Future<void> logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
