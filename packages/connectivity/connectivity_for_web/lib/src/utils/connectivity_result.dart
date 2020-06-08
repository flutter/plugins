import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';

/// Converts an incoming NetworkInformation object into the correct ConnectivityResult.
//
// We can't be more specific on the signature of this method because the API is odd,
// data can come from a static value in the DOM, or as the 'target' of a DOM Event.
//
// If we type info as `NetworkInformation`, Dart will complain with:
// "Uncaught Error: Expected a value of type 'NetworkInformation',
// but got one of type 'NetworkInformation'"
ConnectivityResult networkInformationToConnectivityResult(
    dynamic /* NetworkInformation */ info) {
  if (info == null) {
    return ConnectivityResult.none;
  }
  if (info.downlink == 0 && info.rtt == 0) {
    return ConnectivityResult.none;
  }
  if (info.type != null) {
    return _typeToConnectivityResult(info.type);
  }
  if (info.effectiveType != null) {
    return _effectiveTypeToConnectivityResult(info.effectiveType);
  }
  return ConnectivityResult.none;
}

ConnectivityResult _effectiveTypeToConnectivityResult(String effectiveType) {
  // Possible values:
  /*'2g'|'3g'|'4g'|'slow-2g'*/
  switch (effectiveType) {
    case 'slow-2g':
    case '2g':
    case '3g':
      return ConnectivityResult.mobile;
    default:
      return ConnectivityResult.wifi;
  }
}

ConnectivityResult _typeToConnectivityResult(String type) {
  // Possible values:
  /*'bluetooth'|'cellular'|'ethernet'|'mixed'|'none'|'other'|'unknown'|'wifi'|'wimax'*/
  switch (type) {
    case 'none':
      return ConnectivityResult.none;
    case 'bluetooth':
    case 'cellular':
    case 'mixed':
    case 'other':
    case 'unknown':
      return ConnectivityResult.mobile;
    default:
      return ConnectivityResult.wifi;
  }
}
