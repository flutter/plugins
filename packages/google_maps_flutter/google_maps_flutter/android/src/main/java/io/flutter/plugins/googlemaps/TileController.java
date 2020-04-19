package io.flutter.plugins.googlemaps;

import android.graphics.Bitmap;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Tile;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileProvider;
import com.google.android.gms.maps.model.UrlTileProvider;
import com.squareup.picasso.Picasso;

import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class TileController extends UrlTileProvider  {
    private TileOverlaySpec spec;

    @Override
    public Tile getTile(int x, int y, int z) {
        if (spec == null) return NO_TILE;

        final byte[] tile = loadTile(x, y, z);
        if (tile != null) {
            return new Tile(spec.width, spec.height, tile);
        }

        return NO_TILE;
    }

    private byte[] loadTile(int x, int y, int z) {
        try {
            final Bitmap bitmap = Picasso.get().load(getUrl(x, y, z)).get();
            final ByteArrayOutputStream baos = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 0, baos);
            return baos.toByteArray();
        } catch (Exception e) {
            return null;
        }
    }

    private String getUrl(int x, int y, int z)  {
        String url = spec.rawUrl.replace("{x}", Integer.toString(x));
        url = url.replace("{y}", Integer.toString(y));
        url = url.replace("{z}", Integer.toString(z));

        return url;
    }

    void setSpec(TileOverlaySpec spec) {
        this.spec = spec;
    }

    TileOverlaySpec getSpec() {
        return this.spec;
    }
}
