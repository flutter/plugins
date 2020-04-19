package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TileOverlayController {

    private GoogleMap googleMap;
    private final HashMap<TileController, TileOverlay> providers = new HashMap<>();

    void setGoogleMap(GoogleMap map) {
        googleMap = map;
    }

    void addTileOverlays(Object o) {
        if (googleMap == null) return;
        final List<TileOverlaySpec> specs = Convert.interpretTileSpecs(o);

        for (TileOverlaySpec spec : specs) {
            final TileController controller = new TileController(spec);

            final TileOverlay overlay = googleMap.addTileOverlay(new TileOverlayOptions().tileProvider(controller));
            applySpecOnOverlay(spec, overlay);

            providers.put(controller, overlay);
        }
    }

    void changeTileOverlays(Object o) {
        if (googleMap == null) return;
        final List<TileOverlaySpec> specs = Convert.interpretTileSpecs(o);

        for (TileOverlaySpec spec : specs) {
            for (TileController controller : providers.keySet()) {
                if (controller.spec.rawUrl.equals(spec.rawUrl)) {
                    TileOverlay overlay = providers.get(controller);
                    applySpecOnOverlay(spec, overlay);
                }
            }
        }
    }

    void removeTileOverlays(Object o) {
        if (googleMap == null) return;
        final List<TileOverlaySpec> specs = Convert.interpretTileSpecs(o);

        final List<TileController> toRemove = new ArrayList<>();
        for (TileOverlaySpec spec : specs) {
            for (TileController controller : providers.keySet()) {
                if (controller.spec.rawUrl.equals(spec.rawUrl)) {
                    toRemove.add(controller);
                }
            }
        }

        for (TileController controller : toRemove) {
            final TileOverlay overlay = providers.get(controller);
            if (overlay != null) {
                overlay.remove();
            }

            providers.remove(controller);
        }
    }


    private void applySpecOnOverlay(TileOverlaySpec spec, TileOverlay overlay) {
        if (overlay != null && spec != null) {
            overlay.setVisible(spec.isVisible);
            overlay.setFadeIn(spec.fadeIn);
            overlay.setTransparency(spec.transparency);
            overlay.setZIndex(spec.zIndex);
        }
    }

    void clear() {
        for (TileOverlay overlay : providers.values()) {
            overlay.clearTileCache();
        }
    }
}
