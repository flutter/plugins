// Copyright 2017, the Flutter project authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:async';

import 'package:flutter/services.dart';

import '../gen/fble.pb.dart' as protos;
import 'api.dart';
import 'platform.dart';

class Fble {
  static const namespace = 'io.flutter.plugins.fble';
  static const methodNamespace = namespace + '.method';
  static const eventNamespace = namespace + '.event';
  static const getLocalAdaptersMethod = 'getLocalAdapters';
  static const startScanMethod = 'startScan';
  static const stopScanMethod = 'stopScan';

  static const methodChannel = const MethodChannel(methodNamespace);

  static Future<List<BluetoothAdapter>> get localAdapters async =>
      await _getLocalAdapters();

  static Future<List<BluetoothAdapter>> _getLocalAdapters() async {
    List<int> data = await methodChannel.invokeMethod(getLocalAdaptersMethod);
    protos.GetLocalAdaptersResponse response =
        new protos.GetLocalAdaptersResponse.fromBuffer(data);
    if (response.adapters.isEmpty) {
      print('No Bluetooth adapters found. This could be due to missing or '
            'incorrect platform permissions. On Android, we need '
            'android.permission.BLUETOOTH, android.permission.BLUETOOTH_ADMIN '
            'and either android.permission.ACCESS_COARSE_LOCATION or '
            'android.permission.ACCESS_FINE_LOCATION. On iOS, we need '
            'NSBluetoothPeripheralUsageDescription key in Info.plist.');
      return const [];
    }
    return response.adapters.map((adapter) {
      if (response.platform ==
          protos.GetLocalAdaptersResponse_Platform.ANDROID) {
        return new AndroidBluetoothAdapter(adapter);
      } else {
        return new IosBluetoothAdapter(adapter);
      }
    }).toList();
  }
}
