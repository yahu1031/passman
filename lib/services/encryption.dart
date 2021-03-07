import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passman/secret.dart';

class Encryption extends ChangeNotifier {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  String _encryptString;
  final encrypt.Key key = encrypt.Key.fromUtf8(secretPassKey);
  final encrypt.IV iv = encrypt.IV.fromLength(16);
  String get getString {
    return _encryptString;
  }

  void stringEncryption(String generatedString) {
    final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypt.Encrypted _encryptString =
        encrypter.encrypt(generatedString, iv: iv);
    notifyListeners();
  }
}
