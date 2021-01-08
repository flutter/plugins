package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;

interface GroundOverlayOptionsSink {
    void setConsumeTapEvents(boolean consumeTapEvents);

    void setVisible(boolean visible);

    void setZIndex(float zIndex);

    void setLocation(Object location, Object width, Object height, Object bounds);

    void setBitmapDescriptor(BitmapDescriptor bd);

    void setBearing(float bearing);

    void setTransparency(float transparency);
}