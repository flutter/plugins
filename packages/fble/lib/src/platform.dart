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
import 'plugin.dart';

bool _matchAllServices(
    protos.ScanResult scanResult, List<BluetoothUuid> serviceFilters) {
  Set<BluetoothUuid> foundUuidStrings = scanResult.advertisementData.serviceData
      .map((entry) => BluetoothUuid.fromString(entry.key))
      .toSet();
  return foundUuidStrings.containsAll(serviceFilters);
}

bool _matchAnyDevice(
    protos.ScanResult scanResult, List<DeviceFilter> deviceFilters) =>
    deviceFilters.any((filter) => filter.match(scanResult));

abstract class AbstractBluetoothAdapter extends BluetoothAdapter {
  AbstractBluetoothAdapter(DeviceIdentifier identifier) : super(identifier);

  @override
  Stream<ScanResult> startScan(
      {ScanOption option = BluetoothAdapter.defaultScanOption,
        List<BluetoothUuid> serviceFilters =
            BluetoothAdapter.defaultServiceFilters,
        List<DeviceFilter> deviceFilters =
            BluetoothAdapter.defaultDeviceFilters}) async* {
    if (serviceFilters == null) {
      serviceFilters = const [];
    }
    if (deviceFilters == null) {
      deviceFilters = const [];
    }
    final request = new protos.StartScanRequest()
      ..adapterId = identifier.toString()
      ..serviceUuids.addAll(serviceFilters.map((f) => f.toString()));
    await Fble.methodChannel
        .invokeMethod(Fble.startScanMethod, request.writeToBuffer());
    final scanResultChannel =
    new EventChannel(Fble.eventNamespace + '.scanResult.${identifier}');
    yield* scanResultChannel
        .receiveBroadcastStream()
        .map((List<int> data) => new protos.ScanResult.fromBuffer(data))
        .where((p) =>
    (serviceFilters.isEmpty || _matchAllServices(p, serviceFilters)) &&
        (deviceFilters.isEmpty || _matchAnyDevice(p, deviceFilters)))
        .map((p) => new ScanResult(
        name: p.name,
        identifier: makeDeviceIdentifier(p.remoteId),
        rssi: p.rssi,
        advertisementData: p.advertisementData));
  }

  @override
  Future<List<BluetoothDevice>> get pairedDevices async {
    // TODO
    return <BluetoothDevice>[];
  }

  @override
  Future<Null> stopScan() async {
    await Fble.methodChannel
        .invokeMethod(Fble.stopScanMethod, identifier.toString());
  }

  DeviceIdentifier makeDeviceIdentifier(String opaqueId);
}

class AndroidBluetoothAdapter extends AbstractBluetoothAdapter {
  AndroidBluetoothAdapter(protos.LocalAdapter response)
      : super(MacAddress.fromString(response.opaqueId));

  @override
  DeviceIdentifier makeDeviceIdentifier(String opaqueId) =>
      MacAddress.fromString(opaqueId);
}

class IosBluetoothAdapter extends AbstractBluetoothAdapter {
  IosBluetoothAdapter(protos.LocalAdapter response)
      : super(new DeviceIdentifier(response.opaqueId));

  @override
  DeviceIdentifier makeDeviceIdentifier(String opaqueId) =>
      new DeviceIdentifier(opaqueId);
}
