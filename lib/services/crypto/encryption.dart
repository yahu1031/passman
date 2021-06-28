import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:passman/secret.dart';

final Encryption encryption = Encryption();

class Encryption extends ChangeNotifier {
  final encrypt.Key key = encrypt.Key.fromUtf8(secretPassKey);
  final encrypt.Key uNameKey = encrypt.Key.fromUtf8(uNameSecretPassKey);
  final encrypt.Key uPassKey = encrypt.Key.fromUtf8(uPassSecretPassKey);
  final encrypt.IV iv = encrypt.IV.fromLength(16);
  encrypt.Encrypted stringEncryption(String generatedString) {
    encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key));
    encrypt.Encrypted _encryptData = encrypter.encrypt(generatedString, iv: iv);
    notifyListeners();
    return _encryptData;
  }

  encrypt.Encrypted uNameEncryption(String userName) {
    encrypt.Encrypter uNameEncrypter = encrypt.Encrypter(encrypt.AES(uNameKey));
    encrypt.Encrypted _encryptUName = uNameEncrypter.encrypt(userName, iv: iv);
    notifyListeners();
    return _encryptUName;
  }

  encrypt.Encrypted uPassEncryption(String userPassword) {
    encrypt.Encrypter uPassEncrypter = encrypt.Encrypter(encrypt.AES(uPassKey));
    encrypt.Encrypted _encryptPass =
        uPassEncrypter.encrypt(userPassword, iv: iv);
    notifyListeners();
    return _encryptPass;
  }
}
