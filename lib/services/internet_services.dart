import 'dart:async';

import 'package:http/http.dart' as http;

class FetchIP {
  static Future<String?> getIP() async {
    try {
      Uri uri = Uri.parse('http://api.ipify.org/');
      http.Response response = await http.get(uri);
      return response.statusCode == 200 ? response.body : null;
    } catch (ipTryCatchError) {
      print('IP error: ' + ipTryCatchError.toString());
    }
  }
}
