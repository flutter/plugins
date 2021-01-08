package io.flutter.plugins.googlemaps;


import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;


class GroundOverlayController implements GroundOverlayOptionsSink {
    private final GroundOverlay groundOverlay;
    private final String googleMapsGroundOverlayId;
    private boolean consumeTapEvents;


    GroundOverlayController(GroundOverlay groundOverlay, boolean consumeTapEvents) {
        this.groundOverlay = groundOverlay;
        this.consumeTapEvents = consumeTapEvents;
        this.googleMapsGroundOverlayId = this.groundOverlay.getId();
    }


    boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    @Override
    public void setConsumeTapEvents(boolean consumeTapEvents) {
        this.consumeTapEvents = consumeTapEvents;
    }

    @Override
    public void setVisible(boolean visible) {
        this.groundOverlay.setVisible(visible);
    }

    @Override
    public void setZIndex(float zIndex) {
        this.groundOverlay.setZIndex(zIndex);
    }

    void remove() {
        groundOverlay.remove();
    }

    @Override
    public void setLocation(Object location, Object width, Object height, Object bounds) {
        if (height != null && width != null) {
            this.groundOverlay.setDimensions((float) width, (float) height);
        } else {
            if (width != null) {
                this.groundOverlay.setDimensions((float) width);
            }
        }
        if (location != null) {
            this.groundOverlay.setPosition((LatLng) location);
        }
        if (bounds != null) {
            this.groundOverlay.setPositionFromBounds((LatLngBounds) bounds);
        }
    }

    @Override
    public void setBitmapDescriptor(BitmapDescriptor bd) {
        this.groundOverlay.setImage(bd);
    }

    @Override
    public void setBearing(float bearing) {
        this.groundOverlay.setBearing(bearing);
    }

    @Override
    public void setTransparency(float transparency) {
        this.groundOverlay.setTransparency(transparency);
    }

    String getGoogleMapsGroundOverlayId() {
        return this.googleMapsGroundOverlayId;
    }
}