package io.flutter.plugins.googlemaps;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.google.android.gms.maps.model.Tile;
import com.google.android.gms.maps.model.TileProvider;

import java.util.concurrent.CountDownLatch;

import io.flutter.plugin.common.MethodChannel;

public class TileProviderController implements TileProvider, MethodChannel.Result {

    private static final String TAG = "TileProviderController";

    private final String tileOverlayId;
    private final MethodChannel methodChannel;
    private final Handler handler = new Handler(Looper.getMainLooper());

    private CountDownLatch countDownLatch;
    private Tile tile;

    TileProviderController(MethodChannel methodChannel, String tileOverlayId) {
        this.tileOverlayId = tileOverlayId;
        this.methodChannel = methodChannel;
    }

    @Override
    public Tile getTile(final int x, final int y, final int zoom) {
        countDownLatch = new CountDownLatch(1);
        handler.post(() -> methodChannel.invokeMethod("tileOverlay#getTile",
                Convert.tileOverlayArgumentsToJson(tileOverlayId, x, y, zoom),
                TileProviderController.this));
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            Log.e(TAG, String.format("countDownLatch: can't get tile: x = %d, y= %d, zoom = %d", x, y, zoom), e);
            tile = TileProvider.NO_TILE;
        }
        if (tile == null) {
            tile = TileProvider.NO_TILE;
        }
        return tile;
    }

    @Override
    public void success(Object data) {
        try {
            tile = Convert.interpretTile(data);
        } catch (Exception ex) {
            Log.e(TAG, "Can't parse tile data", ex);
            tile = TileProvider.NO_TILE;
        }
        countDownLatch.countDown();
    }

    @Override
    public void error(String errorCode, String errorMessage, Object data) {
        Log.e(TAG, String.format("Can't get tile: errorCode = %s, errorMessage = %s, date = %s", errorCode, errorCode, data));
        tile = TileProvider.NO_TILE;
        countDownLatch.countDown();
    }

    @Override
    public void notImplemented() {
        tile = TileProvider.NO_TILE;
        Log.e(TAG, "Can't get tile: notImplemented");
        countDownLatch.countDown();
    }
}
