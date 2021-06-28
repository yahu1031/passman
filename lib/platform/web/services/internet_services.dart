import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:passman/secret.dart';
import 'package:http/http.dart' as http;
import 'package:passman/utils/constants.dart';
import 'package:passman/platform/web/model/device_info.dart';
import 'package:passman/platform/web/model/location_model.dart';

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
    if (locationResponse.statusCode >= 200 &&
        locationResponse.statusCode <= 299) {
      return LocationInfo.fromJson(jsonDecode(locationResponse.body));
    } else {
      throw 'Error occured while fetching Area.';
    }
  }
}

// LocationData? _locationData;
// Location location = Location();

// Future<String?> get locationInfo async {
//   _locationData = await location.getLocation();
//   LocationInfo locationData = await FetchLocation().getLocationDetails(
//     _locationData!.latitude!,
//     _locationData!.longitude!,
//   );
//   return locationData.address!.village;
// }

// Future<Position> determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return Future<Position>.error('Location services are disabled.');
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle appropriately.
//       return Future<Position>.error(
//           '''
// Location permissions are permanently denied,
//  we cannot request permissions.''');
//     }

//     if (permission == LocationPermission.denied) {
//       return Future<Position>.error('Location permissions are denied');
//     }
//   }
//   return Geolocator.getCurrentPosition();
// }

WebBrowserInfo? browserInfo;
IconData? browserIcon, platformIcon;
DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

Future<PlatformInfo> get platformInfo async {
  browserInfo = await deviceInfo.webBrowserInfo;
  String? browserPlat = browserInfo!.platform;
  List<String?> brow = browserInfo!.userAgent.split(' ');
  String? brow1 = brow[brow.length - 1]!.replaceAll(RegExp(r'[0-9\/\.]'), '');
  String? brow2 = brow[brow.length - 2]!.replaceAll(RegExp(r'[0-9\/\.]'), '');
  String? brow3 = brow[brow.length - 3]!.replaceAll(RegExp(r'[0-9\/\.]'), '');
  String? browser;
  if (brow3.contains(RegExp(r'[\(\)]'))) {
    if (brow2.contains('Version')) {
      if (brow1.contains('Safari')) {
        browser = 'Safari';
        browserIcon = Iconsdata.safari;
      }
    } else if (brow2.contains('Chrome')) {
      if (brow1.contains('Safari')) {
        browser = 'Chrome';
        browserIcon = Iconsdata.chrome;
      }
    } else if (brow2.contains('Gecko')) {
      if (brow1.contains('Firefox')) {
        browser = 'Firefox';
        browserIcon = Iconsdata.firefox;
      }
    }
  } else if (brow3.contains('Chrome')) {
    if (brow2.contains('Safari')) {
      if (brow1.contains('Edg')) {
        browser = 'Edge';
        browserIcon = Iconsdata.edge;
      } else if (brow1.contains('OPR')) {
        browser = 'Opera';
        browserIcon = Iconsdata.opera;
      }
    }
  }
  if (browserPlat.toLowerCase() == 'win32') {
    return PlatformInfo(os: 'Windows', browser: browser!);
  } else if (browserPlat.toLowerCase() == 'macintel') {
    return PlatformInfo(os: 'Macos', browser: browser!);
  } else {
    return PlatformInfo(os: 'Linux', browser: browser!);
  }
}
