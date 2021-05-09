import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  GoogleSignInProvider() {
    _isSigningIn = false;
  }
  bool? _isSigningIn;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignInAuthentication? googleAuth;
  GoogleSignInAccount? user;
  OAuthCredential? credential;

  // Get uid
  Future<String> getCurrentUid() async => _firebaseAuth.currentUser!.uid;

  // Get current Users
  String getCurrentUser() => _firebaseAuth.currentUser!.displayName!;

  // Get image url
  Object getUserImage() {
    if (_firebaseAuth.currentUser!.photoURL != null) {
      return NetworkImage(
        _firebaseAuth.currentUser!.photoURL!,
      );
    } else {
      return const Icon(Icons.account_circle_outlined);
    }
  }

  bool get isSigningIn => _isSigningIn!;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future<void> login() async {
    isSigningIn = true;
    try {
      // Collecting possible loginable accounts
      user = await googleSignIn.signIn();
      // Checking the user we choose is null or not
      if (user == null) {
        isSigningIn = false;
        return;
      } else {
        // If not null, getting the instance for
        // authentication tokens after sign in.
        googleAuth = await user!.authentication;
        // Getting the accesstoken and id tokens for
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth!.accessToken,
          idToken: googleAuth!.idToken,
        );
        // Signing in the user with caught credentials
        await FirebaseAuth.instance.signInWithCredential(credential!);
        isSigningIn = false;
      }
    }
    // catching Firebase exceptions
    on FirebaseAuthException catch (e) {
      log(e.message.toString());
    }
    // catching Platform exceptions
    on PlatformException catch (err) {
      log(err.details.toString());
      throw (err.message.toString());
    }
    // catching normal exceptions
    catch (ce) {
      log(ce.toString());
    }
  }

  Future<void> logout() async {
    try {
      await googleSignIn
          .disconnect()
          .onError((Object? error, StackTrace stackTrace) async {
        await FirebaseAuth.instance.signOut();
      });
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (firebaseError) {
      throw firebaseError.toString();
    } on PlatformException catch (err) {
      throw err.toString();
    } catch (error) {
      throw error.toString();
    }
  }
}
