import 'package:encrypt/encrypt.dart' as decrypt;
import 'package:logger/logger.dart';
import 'package:passman/.dart';

class Decryption {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  final decrypt.Key key = decrypt.Key.fromUtf8(secretPassKey);
  final decrypt.IV iv = decrypt.IV.fromLength(16);
  String stringDecryption(String encryptedString) {
    decrypt.Encrypter decrypter = decrypt.Encrypter(decrypt.AES(key));
    String decrypted = decrypter.decrypt64(encryptedString, iv: iv);
    return decrypted;
  }
}
