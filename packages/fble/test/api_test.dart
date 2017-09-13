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

import 'package:test/test.dart';

import '../lib/src/api.dart';

main() {
  group('BluetoothUuid', () {
    test('fromString should fail with wrong format', () {
      expect(() => BluetoothUuid.fromString('abc'), throwsFormatException);
      expect(
          () => BluetoothUuid.fromString('00000000-0000-1000-8000-00805f9b34f'),
          throwsFormatException);
      expect(
          () =>
              BluetoothUuid.fromString('00000000-0000-1000-8000-00805f9b34fb0'),
          throwsFormatException);
      expect(
          () =>
              BluetoothUuid.fromString('00000000-0000-1000-8000-00805f9b34fh'),
          throwsFormatException);
    });

    test('fromString should fail if short form is not a hex number', () {
      expect(() => BluetoothUuid.fromString('133G'), throwsFormatException);
      expect(() => BluetoothUuid.fromString('1337133Z'), throwsFormatException);
    });

    test('fromString should parse base UUID', () {
      expect(BluetoothUuid.fromString('00000000-0000-1000-8000-00805f9b34fb'),
          BluetoothUuid.base);
    });

    test('fromInt should fail with ArgumentError', () {
      expect(() => BluetoothUuid.fromInt(-1), throwsArgumentError);
      expect(() => BluetoothUuid.fromInt(0x100000000), throwsArgumentError);
    });

    test('fromInt should work with values in range', () {
      expect(BluetoothUuid.fromInt(0), BluetoothUuid.base);
      expect(BluetoothUuid.fromInt(0x1337),
          BluetoothUuid.fromString('00001337-0000-1000-8000-00805f9b34fb'));
      expect(BluetoothUuid.fromInt(0xFFFFFFFF),
          BluetoothUuid.fromString('ffffffff-0000-1000-8000-00805f9b34fb'));
      expect(BluetoothUuid.fromString('1337'), BluetoothUuid.fromInt(0x1337));
    });
  });

  group('MacAddress', () {
    test('fromString should fail with wrong format', () {
      expect(() => MacAddress.fromString('11:22:33:44:55:6'),
          throwsFormatException);
      expect(() => MacAddress.fromString('11:22:33:44:55:661'),
          throwsFormatException);
      expect(() => MacAddress.fromString('1122:33:44:55:66'),
          throwsFormatException);
      expect(() => MacAddress.fromString('11:22:33:44:55:6h'),
          throwsFormatException);
      expect(() => MacAddress.fromString('11223344556'), throwsFormatException);
      expect(
          () => MacAddress.fromString('1122334455666'), throwsFormatException);
    });

    test('fromString should insert :', () {
      expect(MacAddress.fromString('112233445566'),
          MacAddress.fromString('11:22:33:44:55:66'));
    });
  });
}
