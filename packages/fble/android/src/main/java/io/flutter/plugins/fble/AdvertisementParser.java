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

package io.flutter.plugins.fble;

import com.google.protobuf.ByteString;
import io.flutter.plugins.fble.Protos.AdvertisementData;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.UUID;

/**
 * Parser of Bluetooth Advertisement packets.
 */
class AdvertisementParser {

  /**
   * Parses packet data into {@link AdvertisementData} structure.
   *
   * @param rawData The scan record data.
   * @return An AdvertisementData proto object.
   * @throws ArrayIndexOutOfBoundsException if the input is truncated.
   */
  AdvertisementData parse(byte[] rawData) {
    ByteBuffer data = ByteBuffer.wrap(rawData).asReadOnlyBuffer().order(ByteOrder.LITTLE_ENDIAN);
    AdvertisementData.Builder ret = AdvertisementData.newBuilder();
    boolean seenLongLocalName = false;
    do {
      int length = data.get() & 0xFF;
      if (length == 0) {
        break;
      }
      if (length > data.remaining()) {
        throw new ArrayIndexOutOfBoundsException("Not enough data.");
      }

      int type = data.get() & 0xFF;
      length--;

      switch (type) {
        case 0x08: // Short local name.
        case 0x09: { // Long local name.
          if (seenLongLocalName) {
            // Prefer the long name over the short.
            break;
          }
          byte[] name = new byte[length];
          data.get(name);
          try {
            ret.setLocalName(new String(name, "UTF-8"));
          } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
          }
          if (type == 0x09) {
            seenLongLocalName = true;
          }
          break;
        }
        case 0x0A: { // Power level.
          ret.setTxPowerLevel(data.get());
          break;
        }
        case 0x16: // Service Data with 16 bit UUID.
        case 0x20: // Service Data with 32 bit UUID.
        case 0x21: { // Service Data with 128 bit UUID.
          UUID uuid;
          int remainingDataLength = 0;
          if (type == 0x16 || type == 0x20) {
            long uuidValue;
            if (type == 0x16) {
              uuidValue = data.getShort() & 0xFFFF;
              remainingDataLength = length - 2;
            } else {
              uuidValue = data.getInt() & 0xFFFFFFFF;
              remainingDataLength = length - 4;
            }
            uuid = UUID.fromString(String.format("%08x-0000-1000-8000-00805f9b34fb", uuidValue));
          } else {
            long msb = data.getLong();
            long lsb = data.getLong();
            uuid = new UUID(msb, lsb);
            remainingDataLength = length - 16;
          }
          byte[] remainingData = new byte[remainingDataLength];
          data.get(remainingData);
          ret.putServiceData(uuid.toString(), ByteString.copyFrom(remainingData));
          break;
        }
        case 0xFF: {// Manufacturer specific data.
          byte[] msd = new byte[length];
          data.get(msd);
          ret.setManufacturerData(ByteString.copyFrom(msd));
          break;
        }
        default: {
          data.position(data.position() + length);
          break;
        }
      }
    } while (true);
    return ret.build();
  }
}
