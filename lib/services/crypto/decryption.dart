import 'package:encrypt/encrypt.dart' as decrypt;
import 'package:passman/.dart';

Decryption decryption = Decryption();

class Decryption {
  final decrypt.Key key = decrypt.Key.fromUtf8(secretPassKey);
  final decrypt.Key uNameKey = decrypt.Key.fromUtf8(uNameSecretPassKey);
  final decrypt.Key uPassKey = decrypt.Key.fromUtf8(uPassSecretPassKey);
  final decrypt.IV iv = decrypt.IV.fromLength(16);
  String stringDecryption(String encryptedString) {
    try {
      decrypt.Encrypter decrypter = decrypt.Encrypter(decrypt.AES(key));
      String decrypted = decrypter.decrypt64(encryptedString, iv: iv);
      return decrypted;
    } catch (decryptErr) {
      throw decryptErr.toString();
    }
  }

  String uNameDecryption(String encryptedUName) {
    try {
      decrypt.Encrypter uNameDecrypter =
          decrypt.Encrypter(decrypt.AES(uNameKey));
      String decryptedUName = uNameDecrypter.decrypt64(encryptedUName, iv: iv);
      return decryptedUName;
    } catch (decryptErr) {
      throw decryptErr.toString();
    }
  }

  String uPassDecryption(String encryptedUPass) {
    try {
      decrypt.Encrypter uPassDecrypter =
          decrypt.Encrypter(decrypt.AES(uPassKey));
      String decryptedUPass = uPassDecrypter.decrypt64(encryptedUPass, iv: iv);
      return decryptedUPass;
    } catch (decryptErr) {
      throw decryptErr.toString();
    }
  }
}
