import 'dart:math';
import 'package:flutter/material.dart';

class RandomNumberGenerator extends ChangeNotifier {
  final Random _rnd = Random();
  String _randomString;
  static const String _chars =
      '0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  String get getString {
    return _randomString;
  }

  void randomStringGenerator(int length) {
    _randomString = String.fromCharCodes(
      Iterable<int>.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );
    notifyListeners();
  }
}
