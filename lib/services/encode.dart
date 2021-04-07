import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:passman/services/utilities/get_capacity.dart';
import 'package:passman/services/utilities/other_services.dart';

class EncodeRequest {
  EncodeRequest(this.original, this.msg, {this.token});
  imglib.Image original;
  String msg;
  String? token;

  bool shouldEncrypt() => (token != null && token != '');
}

class EncodeResponse {
  EncodeResponse(this.editableImage, this.displayableImage, this.data);
  imglib.Image editableImage;
  Image displayableImage;
  Uint8List data;
}

class EncryptQR {
  EncryptQR({this.otp, this.token});
  int? otp;
  String? token;

  bool shouldEncrypt() => (token != null && token != '');
}

int encodeOnePixel(int pixel, int msg) {
  if (msg != 1 && msg != 0) {
    throw FlutterError('msg_encode_bit_more_than_1_bit');
  }
  int lastBitMask = 254;
  int encoded = (pixel & lastBitMask) | msg;
  return encoded;
}

/// * Encoding hashed String into Image

EncodeResponse encodeMessageIntoImage(EncodeRequest req) {
  Uint16List img = Uint16List.fromList(req.original.getBytes().toList());
  String msg = req.msg;
  String token = req.token!;
  if (req.shouldEncrypt()) {
    crypto.Key key = crypto.Key.fromUtf8(padCryptionKey(token));
    crypto.IV iv = crypto.IV.fromLength(16);
    crypto.Encrypter encrypter = crypto.Encrypter(crypto.AES(key));
    crypto.Encrypted encrypted = encrypter.encrypt(msg, iv: iv);
    msg = encrypted.base64;
  }
  Uint16List encodedImg = img;
  if (getEncoderCapacity(img) < getMsgSize(msg)) {
    throw FlutterError('image_capacity_not_enough');
  }

  /// *encoding the message

  Uint16List expandedMsg = expandMsg(msg2bytes(msg));
  Uint16List paddedMsg = padMsg(getEncoderCapacity(img), expandedMsg);

  if (paddedMsg.length != getEncoderCapacity(img)) {
    throw FlutterError('msg_container_size_not_match');
  }
  for (int i = 0; i < getEncoderCapacity(img); ++i) {
    encodedImg[i] = encodeOnePixel(img[i], paddedMsg[i]);
  }
  imglib.Image editableImage = imglib.Image.fromBytes(
      req.original.width, req.original.height, encodedImg.toList());
  Image displayableImage = Image.memory(
      Uint8List.fromList(
        imglib.encodePng(editableImage),
      ),
                                        fit: BoxFit.cover,
  );
  Uint8List data = Uint8List.fromList(imglib.encodePng(editableImage));
  EncodeResponse response =
      EncodeResponse(editableImage, displayableImage, data);
  return response;
}

Future<EncodeResponse> encodeMessageIntoImageAsync(EncodeRequest req,
    {required BuildContext? context}) async {
  EncodeResponse res =
      await compute(encodeMessageIntoImage, req).catchError((dynamic onError) {
    print('Error while encoding message into image : ${onError.toString()}');
  });
  return res;
}
