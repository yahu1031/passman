import 'package:flutter/material.dart';

/// Encode Request
///
/// {@category Services: Requests}
class EncodeRequest {
  EncodeRequest(this.original, this.msg, {this.token});
  Image original;
  String msg;
  String? token;


  bool shouldEncrypt() => (token != null && token != '');
}

class EncryptQR {
  EncryptQR({this.otp, this.token});
  int? otp;
  String? token;

  bool shouldEncrypt() => (token != null && token != '');
}
