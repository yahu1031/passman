import 'dart:math';

import 'package:flutter/widgets.dart';

class TokenGenerator extends ChangeNotifier {
  static const String chars =
      '0123456789AaBbCcDdEeFfGgHhIiJjKkMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  Random rnd = Random();
  String randomStringGenerator() {
    String randomToken = String.fromCharCodes(
      Iterable<int>.generate(
        6,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
    notifyListeners();
    return randomToken;
  }
}
