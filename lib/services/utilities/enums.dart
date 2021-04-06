/// Loading State
///
/// {@category Services: States}
enum LoadingState {
  LOADING,
  ERROR,
  PENDING,
  SUCCESS,
}

/// Decode Result State
///
/// {@category Services: States}
enum DecodeResultState {
  SUCCESS,
  ERROR,
}

/// App Running State
///
/// {@category Services: States}
enum AppRunningState {
  INTEGRATION_TEST,
  UNIT_TEST,
  DEVELOPMENT,
  PRODUCTION,
}

/// Platform State
///
/// {@category Services: States}
enum PlatformState {
  IPAD,
  IPHONE,
  GENERIC,
}
