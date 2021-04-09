class LocationInfo {
  LocationInfo({
    required this.address,
  });

  LocationInfo.fromJson(Map<String, dynamic> json) {
    address = Address.fromJson(json['address']);
  }

  Address? address;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address!.toJson();
    return data;
  }
}


class Address {
  Address({
    required this.suburb,
    required this.village,
    required this.county,
    required this.stateDistrict,
    required this.state,
    required this.postcode,
    required this.country,
    required this.countryCode,
  });

  Address.fromJson(Map<String, dynamic> json) {
    suburb = json['suburb'];
    village = json['village'];
    county = json['county'];
    stateDistrict = json['state_district'];
    state = json['state'];
    postcode = json['postcode'];
    country = json['country'];
    countryCode = json['country_code'];
  }

  String? suburb,
      village,
      county,
      stateDistrict,
      state,
      postcode,
      country,
      countryCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['suburb'] = suburb;
    data['village'] = village;
    data['county'] = county;
    data['state_district'] = stateDistrict;
    data['state'] = state;
    data['postcode'] = postcode;
    data['country'] = country;
    data['country_code'] = countryCode;
    return data;
  }
}
