import 'dart:math';

class RandomNumberGenerator {
  final Random _rnd = Random();
  static const String chars =
      '0123456789AaBbCcDdEeFfGgHhIiJjKkMmNnOoPpQqRrSsTtUuVvWwXxYyZz';

  String randomStringGenerator(int length) => String.fromCharCodes(
      Iterable<int>.generate(
        length,
        (_) => chars.codeUnitAt(
          _rnd.nextInt(chars.length),
        ),
      ),
    );
}
