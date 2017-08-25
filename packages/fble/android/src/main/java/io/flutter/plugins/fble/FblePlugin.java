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

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothAdapter.LeScanCallback;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.util.Pair;
import com.google.common.annotations.VisibleForTesting;
import com.google.protobuf.InvalidProtocolBufferException;
import io.flutter.plugins.fble.Protos.AdvertisementData;
import io.flutter.plugins.fble.Protos.GetLocalAdaptersResponse;
import io.flutter.plugins.fble.Protos.LocalAdapter;
import io.flutter.plugins.fble.Protos.ScanResult;
import io.flutter.plugins.fble.Protos.StartScanRequest;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.UUID;

/**
 * Flutter Bluetooth Low Energy plugin.
 */
public class FblePlugin implements MethodCallHandler {

  private static final String GET_LOCAL_ADAPTERS = "getLocalAdapters";
  private static final String START_SCAN = "startScan";
  private static final String STOP_SCAN = "stopScan";
  private static final String NAMESPACE = "io.flutter.plugin.fble";
  private static final String METHOD_NAMESPACE = NAMESPACE + ".method";
  private static final String EVENT_NAMESPACE = NAMESPACE + ".event";

  private final Registrar registrar;
  private final AdvertisementParser parser;
  private final HashMap<String, Pair<EventChannel, AdapterSpecificScanCallback>> scanCallbacks;

  FblePlugin(Registrar registrar, AdvertisementParser parser) {
    this.registrar = registrar;
    this.parser = parser;
    scanCallbacks = new HashMap<>();
  }

  /**
   * Registers this native plugin with Flutter.
   *
   * @param registrar The Flutter plugin registrar.
   */
  public static void registerWith(Registrar registrar) {
    AdvertisementParser parser = new AdvertisementParser();
    FblePlugin myself = new FblePlugin(registrar, parser);
    MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "fble");
    methodChannel.setMethodCallHandler(myself);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (GET_LOCAL_ADAPTERS.equals(call.method)) {
      getLocalAdapters(call, result);
    } else if (START_SCAN.equals(call.method)) {
      startScan(call, result);
    } else if (STOP_SCAN.equals(call.method)) {
      stopScan(call, result);
    } else {
      result.notImplemented();
    }
  }

  private BluetoothAdapter lookupAdapter(String _1) {
    // There is only one in Android.
    BluetoothManager bluetoothManager =
        (BluetoothManager) registrar.activity().getSystemService(Context.BLUETOOTH_SERVICE);
    return bluetoothManager.getAdapter();
  }

  @VisibleForTesting
  void getLocalAdapters(MethodCall _1, Result result) {
    // TODO: Request permissions and return empty list if not satisfied.
    BluetoothManager bluetoothManager =
        (BluetoothManager) registrar.activity().getSystemService(Context.BLUETOOTH_SERVICE);
    // Only one adapter in Android.
    BluetoothAdapter adapter = bluetoothManager.getAdapter();
    GetLocalAdaptersResponse proto = GetLocalAdaptersResponse.newBuilder()
        .setPlatform(GetLocalAdaptersResponse.Platform.ANDROID)
        .addAdapters(LocalAdapter.newBuilder().setOpaqueId(adapter.getAddress()))
        .build();
    result.success(proto.toByteArray());
  }

  @VisibleForTesting
  void startScan(MethodCall call, Result result) {
    // TODO: Request permission.
    byte[] data = call.arguments();
    StartScanRequest request = null;
    try {
      request = StartScanRequest.newBuilder().mergeFrom(data).build();
    } catch (InvalidProtocolBufferException e) {
      result.error("RuntimeException", e.getMessage(), e);
    }

    String adapterId = request.getAdapterId();
    BluetoothAdapter adapter = lookupAdapter(adapterId);
    EventChannel eventChannel = new EventChannel(registrar.messenger(),
        String.format("%s.scanResult.%s", EVENT_NAMESPACE, adapterId));

    AdapterSpecificScanCallback scanCallback;
    synchronized (scanCallbacks) {
      Pair<EventChannel, AdapterSpecificScanCallback> pair = scanCallbacks.get(adapterId);
      if (pair != null) {
        // Stop existing scan.
        adapter.stopLeScan(pair.second);
        pair.first.setStreamHandler(null);
      }
      scanCallback = new AdapterSpecificScanCallback(adapterId, parser);
      pair = new Pair<>(eventChannel, scanCallback);
      scanCallbacks.put(adapterId, pair);
    }

    eventChannel.setStreamHandler(scanCallback);

    UUID[] uuids = new UUID[request.getServiceUuidsCount()];
    int i = 0;
    for (String uuid : request.getServiceUuidsList()) {
      uuids[i++] = UUID.fromString(uuid);
    }
    if (uuids.length > 0) {
      adapter.startLeScan(uuids, scanCallback);
    } else {
      adapter.startLeScan(scanCallback);
    }
    result.success(null);
  }

  @VisibleForTesting
  void stopScan(MethodCall call, Result result) {
    String adapterId = call.arguments();
    Pair<EventChannel, AdapterSpecificScanCallback> pair;
    synchronized (scanCallbacks) {
      pair = scanCallbacks.get(adapterId);
      if (pair == null) {
        return;
      }
      scanCallbacks.remove(adapterId);
    }
    AdapterSpecificScanCallback scanCallback = pair.second;
    scanCallback.stop();
    pair.first.setStreamHandler(null);

    BluetoothAdapter adapter = lookupAdapter(adapterId);
    adapter.stopLeScan(scanCallback);
    result.success(null);
  }

  private static class AdapterSpecificScanCallback implements LeScanCallback, StreamHandler {

    // TODO: Use LeBluetoothScanner instead of this deprecated API.
    private final String id;
    private final AdvertisementParser parser;
    private EventSink eventSink;

    AdapterSpecificScanCallback(String id, AdvertisementParser parser) {
      this.id = id;
      this.parser = parser;
    }

    @Override
    public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
      AdvertisementData ads = parser.parse(scanRecord);
      ScanResult.Builder scanResult = ScanResult.newBuilder()
          .setRemoteId(device.getAddress())
          .setRssi(rssi)
          .setAdvertisementData(ads);
      // TODO: Fill in "connectable" on Android O and above.
      if (device.getName() != null) {
        scanResult.setName(device.getName());
      }
      if (eventSink != null) {
        eventSink.success(scanResult.build().toByteArray());
      }
    }

    @Override
    public void onListen(Object o, EventSink eventSink) {
      this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      eventSink = null;
    }

    void stop() {
      if (eventSink != null) {
        eventSink.endOfStream();
      }
    }
  }
}
