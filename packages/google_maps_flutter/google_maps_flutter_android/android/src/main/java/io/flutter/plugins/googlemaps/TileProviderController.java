// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.android.gms.maps.model.Tile;
import com.google.android.gms.maps.model.TileProvider;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

class TileProviderController implements TileProvider {

  private static final String TAG = "TileProviderController";

  private final String tileOverlayId;
  private final MethodChannel methodChannel;
  private final Handler handler = new Handler(Looper.getMainLooper());

  TileProviderController(MethodChannel methodChannel, String tileOverlayId) {
    this.tileOverlayId = tileOverlayId;
    this.methodChannel = methodChannel;
  }

  @Override
  public Tile getTile(final int x, final int y, final int zoom) {
    Worker worker = new Worker(x, y, zoom);
    return worker.getTile();
  }

  private final class Worker implements MethodChannel.Result {

    private final CountDownLatch countDownLatch = new CountDownLatch(1);
    private final int x;
    private final int y;
    private final int zoom;
    private Map<String, ?> result;

    Worker(int x, int y, int zoom) {
      this.x = x;
      this.y = y;
      this.zoom = zoom;
    }

    @NonNull
    Tile getTile() {
      handler.post(
          () ->
              methodChannel.invokeMethod(
                  "tileOverlay#getTile",
                  Convert.tileOverlayArgumentsToJson(tileOverlayId, x, y, zoom),
                  this));
      try {
        // Because `methodChannel.invokeMethod` is async, we use a `countDownLatch` make it synchronized.
        countDownLatch.await();
      } catch (InterruptedException e) {
        Log.e(
            TAG,
            String.format("countDownLatch: can't get tile: x = %d, y= %d, zoom = %d", x, y, zoom),
            e);
        return TileProvider.NO_TILE;
      }
      try {
        return Convert.interpretTile(result);
      } catch (Exception e) {
        Log.e(TAG, "Can't parse tile data", e);
        return TileProvider.NO_TILE;
      }
    }

    @Override
    @SuppressWarnings("unchecked")
    public void success(Object data) {
      result = (Map<String, ?>) data;
      countDownLatch.countDown();
    }

    @Override
    public void error(String errorCode, String errorMessage, Object data) {
      Log.e(
          TAG,
          String.format(
              "Can't get tile: errorCode = %s, errorMessage = %s, date = %s",
              errorCode, errorCode, data));
      result = null;
      countDownLatch.countDown();
    }

    @Override
    public void notImplemented() {
      Log.e(TAG, "Can't get tile: notImplemented");
      result = null;
      countDownLatch.countDown();
    }
  }
}
