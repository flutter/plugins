import 'dart:async';
import 'dart:ffi';

import 'package:connectivity_platform_interface/connectivity_platform_interface.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

const VARIANT_TRUE = -1;
const VARIANT_FALSE = 0;

class ConnectivityWindows extends ConnectivityPlatform {
  Future<ConnectivityResult> checkConnectivity() async {
    var hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (FAILED(hr)) {
      throw WindowsException(hr);
    }

    final netManager = NetworkListManager.createInstance();

    try {
      return netManager.IsConnected == VARIANT_TRUE
          ? ConnectivityResult.wifi
          : ConnectivityResult.none;
    } finally {
      calloc.free(netManager.ptr);

      CoUninitialize();
    }
  }

  // TODO(Sunbreak)
  Stream<ConnectivityResult> get onConnectivityChanged => Stream.empty();
}