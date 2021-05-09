@JS('navigator.geolocation')
library jslocation;

import 'package:js/js.dart';

@JS('detectUserLocation')
// external void detectUserLocation();

// @JS('getCurrentPosition')
external void detectUserLocation(
    // ignore: use_function_type_syntax_for_parameters
    Function success(GeolocationPosition pos));

@JS()
@anonymous
class GeolocationCoordinates {
  external factory GeolocationCoordinates({
    double latitude,
    double longitude,
  });

  external double get latitude;
  external double get longitude;
}

@JS()
@anonymous
class GeolocationPosition {
  external factory GeolocationPosition({GeolocationCoordinates coords});

  external GeolocationCoordinates get coords;
}
