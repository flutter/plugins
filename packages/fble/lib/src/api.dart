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

import 'package:collection/collection.dart';

import '../gen/fble.pb.dart' as protos;

/// A physical Bluetooth transceiver module in the system.
///
/// A system might have any number of adapters. Each of them usually owns a
/// separate radio that is used to communicate with other devices.
abstract class BluetoothAdapter {
  const BluetoothAdapter(this.identifier);

  /// Returns a list of paired (bonded) devices.
  Future<List<BluetoothDevice>> get pairedDevices;

  final DeviceIdentifier identifier;

  static const defaultScanOption = const ScanOption();
  static const defaultDeviceFilters = const [];
  static const defaultServiceFilters = const [];

  /// Starts the scan for other devices in the periphery.
  ///
  /// Not all [option] will be honored, depending on the underlying platform.
  /// The [serviceFilters] are "AND" filters. A [ScanResult] must match all of
  /// the specified UUIDs for it to be accepted. The [deviceFilters] are "OR"
  /// filters. If a [ScanResult] matches any of the filters, that scan result
  /// will be selected. An empty or `null` filter argument will accept all
  /// results.
  ///
  /// A scan will continue until [stopScan] is called. It is important to stop
  /// the scan as soon as possible to conserve power. While a scan is happening,
  /// a [startScan] call will end the previous one.
  Stream<ScanResult> startScan(
      {ScanOption option = defaultScanOption,
      List<BluetoothUuid> serviceFilters = defaultServiceFilters,
      List<DeviceFilter> deviceFilters = defaultDeviceFilters});

  /// Stops the current scan attempt if there is one.
  Future<Null> stopScan();
}

/// A Bluetooth device that is found or paired.
class BluetoothDevice {
  DeviceIdentifier identifier;
}

/// Information obtained from scanning.
// TODO: Renamed to AdvertisedPacket?
class ScanResult {
  const ScanResult(
      {this.name, this.identifier, this.advertisementData, this.rssi});

  /// Name of the device.
  final String name;
  final DeviceIdentifier identifier;
  final protos.AdvertisementData advertisementData;

  /// Received signal strength indicator, in decibels.
  final int rssi;
}

/// Operating mode of a scan.
///
/// Only honored in Android at the moment.
// Note: this should be an enum but Dart enum does not support value assignment.
class ScanMode {
  const ScanMode(this.value);

  static const lowPower = const ScanMode(0);
  static const balanced = const ScanMode(1);
  static const lowLatency = const ScanMode(2);
  static const opportunistic = const ScanMode(-1);

  final int value;
}

/// Option to [BluetoothAdapter.startScan].
class ScanOption {
  const ScanOption({this.scanMode = ScanMode.lowLatency});

  final ScanMode scanMode;
}

/// A filter to select a [ScanResult].
///
/// This is an "AND" filter. If any argument is provided, it must match in
/// order for this filter to accept.
class DeviceFilter {
  const DeviceFilter({this.name, this.identifier});

  bool match(protos.ScanResult result) {
    return (name == null || name == result.name) &&
        (identifier == null ||
            identifier == new DeviceIdentifier(result.remoteId));
  }

  final String name;
  final DeviceIdentifier identifier;
}

/// An identifier to distinguish one device from another.
///
/// This is platform dependent and should be treated as an opaque object.
class DeviceIdentifier {
  const DeviceIdentifier(this.id);

  final String id;

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      other is DeviceIdentifier && compareAsciiLowerCase(id, other.id) == 0;

  @override
  int get hashCode => id.hashCode;
}

/// A MAC address.
class MacAddress extends DeviceIdentifier {
  /// Constructs an object from a proper [address].
  const MacAddress.proper(String address) : super(address);

  /// Parses and returns a [MacAddress] object from [input].
  ///
  /// Throws [FormatException] if [input] is not parsable to a MAC address.
  static MacAddress fromString(String input) {
    input = input.toLowerCase();
    if (input.contains(':')) {
      if (!_macPatternWithColon.hasMatch(input)) {
        throw new FormatException('Not in MAC address format', input);
      }
    } else {
      if (!_macPatternWithoutColon.hasMatch(input)) {
        throw new FormatException('Not in MAC address format', input);
      }
      // Insert colons.
      input = new Iterable.generate(6, (i) => i * 2)
          .map((i) => input.substring(i, i + 2))
          .join(':');
    }
    return new MacAddress.proper(input);
  }

  static final RegExp _macPatternWithColon =
      new RegExp('^([0-9a-f]{2}:){5}[0-9a-f]{2}\$');
  static final RegExp _macPatternWithoutColon = new RegExp('^[0-9a-f]{12}\$');
}

/// A Bluetooth UUID value.
class BluetoothUuid {
  /// Constructs an object from a proper [uuid].
  const BluetoothUuid.proper(this.uuid);

  /// Returns a [BluetoothUuid] from a short form [uuid].
  ///
  /// Throws [FormatException] if [uuid] is not within range of a 32-bit number.
  static BluetoothUuid fromInt(int uuid) {
    if (uuid < 0 || uuid > 0xFFFFFFFF) {
      throw new ArgumentError.value(
          uuid, 'uuid', 'Short UUID must be limited to 32-bit');
    }
    return new BluetoothUuid.proper(
        uuid.toRadixString(16).padLeft(8, '0') + _baseString.substring(8));
  }

  /// Parses and returns a [BluetoothUuid] object from [input].
  ///
  /// Throws [FormatException] if [input] is not parsable to a UUID.
  static BluetoothUuid fromString(String input) {
    if (input.length == 4 || input.length == 8) {
      // Short form, eg "FEAA". In iOS CBUUID.uuidString returns this form.
      return BluetoothUuid.fromInt(int.parse(input, radix: 16));
    }
    input = input.toLowerCase();
    if (!_uuidPattern.hasMatch(input)) {
      throw new FormatException('Not in UUID format', input);
    }
    return new BluetoothUuid.proper(input);
  }

  static const _baseString = '00000000-0000-1000-8000-00805f9b34fb';
  static final _uuidPattern = new RegExp(
      '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\$');

  /// The base UUID used to construct proper UUIDs from 16-bit or 32-bit values.
  static const base = const BluetoothUuid.proper(_baseString);

  final String uuid;

  @override
  String toString() => uuid;

  @override
  bool operator ==(Object other) =>
      other is BluetoothUuid && compareAsciiLowerCase(uuid, other.uuid) == 0;

  @override
  int get hashCode => uuid.hashCode;
}
