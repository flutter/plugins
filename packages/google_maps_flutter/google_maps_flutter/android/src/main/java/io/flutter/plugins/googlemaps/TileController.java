package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.UrlTileProvider;

import java.net.MalformedURLException;
import java.net.URL;

public class TileController extends UrlTileProvider  {
    final TileOverlaySpec spec;

    public TileController(TileOverlaySpec spec) {
        super(spec.width, spec.height);
        this.spec = spec;
    }

    @Override
    public URL getTileUrl(int x, int y, int z) {
        try {
            return new URL(getUrlString(x, y, z));
        } catch (MalformedURLException e) {
            return null;
        }
    }

    private String getUrlString(int x, int y, int z)  {
        String url = spec.rawUrl.replace("{x}", Integer.toString(x));
        url = url.replace("{y}", Integer.toString(y));
        url = url.replace("{z}", Integer.toString(z));

        return url;
    }
}
