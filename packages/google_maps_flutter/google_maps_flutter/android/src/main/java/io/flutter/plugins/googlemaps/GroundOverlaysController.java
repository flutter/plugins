package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.GroundOverlayOptions;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

class GroundOverlaysController {

    private GoogleMap googleMap;
    private final Map<String, GroundOverlayController> groundOverlayIdToController;
    private final Map<String, String> googleMapsGroundOverlayIdToDartOverlayId;
    private MethodChannel methodChannel;

    GroundOverlaysController(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
        this.groundOverlayIdToController = new HashMap<>();
        this.googleMapsGroundOverlayIdToDartOverlayId = new HashMap<>();
    }

    void setGoogleMap(GoogleMap googleMap) {
        this.googleMap = googleMap;
    }

    void addOverlays(List<Object> overlaysToAdd) {
        if (overlaysToAdd != null) {
            for (Object polygonToAdd : overlaysToAdd) {
                addOverlay(polygonToAdd);
            }
        }
    }

    private void addOverlay(Object overlay) {
        if (overlay == null) {
            return;
        }

        GroundOverlayBuilder groundOverlayBuilder = new GroundOverlayBuilder();
        String groundOverlayId = Convert.interpretGroundOverlayOptions(overlay, groundOverlayBuilder);
        GroundOverlayOptions options = groundOverlayBuilder.build();
        addGroundOverlay(groundOverlayId, options, groundOverlayBuilder.consumeTapEvents());
    }

    private void addGroundOverlay(
            String groundOverlayId, GroundOverlayOptions groundOverlayOptions, boolean consumeTapEvents) {
        final GroundOverlay groundOverlay = googleMap.addGroundOverlay(groundOverlayOptions);

        GroundOverlayController controller = new GroundOverlayController(groundOverlay, consumeTapEvents);
        groundOverlayIdToController.put(groundOverlayId, controller);
        googleMapsGroundOverlayIdToDartOverlayId.put(groundOverlay.getId(), groundOverlayId);

    }

    boolean onGroundOverlayTap(String googleOverlayId) {
        String overlayId = googleMapsGroundOverlayIdToDartOverlayId.get(googleOverlayId);
        if (overlayId == null) {
            return false;
        }
        methodChannel.invokeMethod("groundOverlay#onTap", Convert.groundOverlayIdToJson(overlayId));
        GroundOverlayController groundOverlayController = groundOverlayIdToController.get(overlayId);
        if (groundOverlayController != null) {
            return groundOverlayController.consumeTapEvents();
        }
        return false;
    }

    void changeGroundOverlays(List<Object> groundOverlaysToChange) {
        if (groundOverlaysToChange != null) {
            for (Object groundOverlayToChange : groundOverlaysToChange) {
                changeGroundOverlay(groundOverlayToChange);
            }
        }
    }

    private void changeGroundOverlay(Object groundOverlay) {
        if (groundOverlay == null) {
            return;
        }
        String groundOverlayId = getGroundOverlayId(groundOverlay);
        GroundOverlayController groundOverlayController = groundOverlayIdToController.get(groundOverlayId);
        if (groundOverlayController != null) {
            Convert.interpretGroundOverlayOptions(groundOverlay, groundOverlayController);
        }
    }

    void removeGroundOverlays(List<Object> groundOverlaysToRemove) {
        if (groundOverlaysToRemove == null) {
            return;
        }

        for (Object rawGroundOverlayId : groundOverlaysToRemove) {
            if (rawGroundOverlayId == null) {
                continue;
            }
            String groundOverlayId = (String) rawGroundOverlayId;
            final GroundOverlayController groundOverlayController = groundOverlayIdToController.remove(groundOverlayId);
            if (groundOverlayController != null) {
                groundOverlayController.remove();
                googleMapsGroundOverlayIdToDartOverlayId.remove(groundOverlayController.getGoogleMapsGroundOverlayId());
            }
        }
    }

    @SuppressWarnings("unchecked")
    private static String getGroundOverlayId(Object overlay) {
        Map<String, Object> overlayMap = (Map<String, Object>) overlay;
        return (String) overlayMap.get("groundOverlayId");
    }
}