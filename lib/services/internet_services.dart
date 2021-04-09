import 'dart:async';
import 'dart:convert';
import 'package:passman/.dart';
import 'package:http/http.dart' as http;
import 'package:passman/models/location_info.dart';

class FetchIP {
  static Future<String?> getIP() async {
    try {
      Uri uri = Uri.parse('https://api.ipify.org/');
      http.Response response = await http.get(uri);
      return response.statusCode == 200 ? response.body : null;
    } catch (ipTryCatchError) {
      throw 'IP error: ' + ipTryCatchError.toString();
    }
  }
}

class FetchLocation {
  Future<LocationInfo> getLocationDetails(double lat, double lon) async {
    Uri locationUri = Uri.parse(
        'https://us1.locationiq.com/v1/reverse.php?key=$geoEncodingAPI&lat=$lat&lon=$lon&format=json');
    http.Response locationResponse = await http.get(locationUri);
    bool isError = !locationResponse.statusCode.between(200, 299);
    if (!isError) {
      return LocationInfo.fromJson(jsonDecode(locationResponse.body));
    } else {
      throw 'Error occured while fetching Area.';
    }
  }
}

extension ExtendedInt on int {
  bool between(int begin, int end) => this >= begin && this <= end;
}
