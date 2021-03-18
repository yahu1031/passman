import 'dart:math';

class RandomNumberGenerator {
  final Random _rnd = Random();
  static const String _chars =
      '0123456789AaBbCcDdEeFfGgHhIiJjKkMmNnOoPpQqRrSsTtUuVvWwXxYyZz';

  String randomStringGenerator(int length) => String.fromCharCodes(
      Iterable<int>.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );
}
