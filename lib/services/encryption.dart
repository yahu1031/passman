import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:logger/logger.dart';
import 'package:passman/secret.dart';

class Encryption {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  final encrypt.Key key = encrypt.Key.fromUtf8(secretPassKey);
  final encrypt.IV iv = encrypt.IV.fromLength(16);

  encrypt.Encrypted stringEncryption(String generatedString) {
    final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key, iv));
    final encrypt.Encrypted _encryptData = encrypter.encrypt(generatedString);
    return _encryptData;
  }
}
