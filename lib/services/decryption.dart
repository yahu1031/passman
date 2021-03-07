import 'package:encrypt/encrypt.dart' as decrypt;
import 'package:logger/logger.dart';
import 'package:passman/secret.dart';

class Decryption {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  final decrypt.Key key = decrypt.Key.fromUtf8(secretPassKey);
  final decrypt.IV iv = decrypt.IV.fromLength(16);
  String stringDecryption(decrypt.Encrypted encryptedString) {
    final decrypt.Encrypter decrypter = decrypt.Encrypter(decrypt.AES(key));
    final String decrypted = decrypter.decrypt(encryptedString, iv: iv);
    return decrypted;
  }
}
