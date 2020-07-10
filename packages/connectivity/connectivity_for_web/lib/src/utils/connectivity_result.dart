import 'dart:js_util';
import 'package:connectivity_for_web/src/generated/network_information_types.dart';
import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';

/// Converts an incoming NetworkInformation object into the correct ConnectivityResult.
ConnectivityResult networkInformationToConnectivityResult(
  NetworkInformation info,
) {
  if (info == null) {
    return ConnectivityResult.none;
  }

  // TODO: Remove this before pushing
  try {
    num dl = info.downlink;
    print(dl);
  } catch (e) {
    print(e);
  }

  num downlink = getProperty(info, 'downlink');
  num rtt = getProperty(info, 'rtt');
  if (downlink == 0 && rtt == 0) {
    return ConnectivityResult.none;
  }
  String effectiveType = getProperty(info, 'effectiveType');
  if (effectiveType != null) {
    return _effectiveTypeToConnectivityResult(effectiveType);
  }
  String type = getProperty(info, 'type');
  if (type != null) {
    return _typeToConnectivityResult(type);
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
