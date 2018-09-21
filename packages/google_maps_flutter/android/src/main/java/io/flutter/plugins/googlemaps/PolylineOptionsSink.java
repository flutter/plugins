package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;

import java.util.List;

interface PolylineOptionsSink {

    void setPoints(List<LatLng> points);

    void setClickable(boolean clickable);

    void setColor(int color);

    void setEndCap(Cap endCap);

    void setGeodesic(boolean geodesic);

    void setJointType(int jointType);

    void setPattern(List<PatternItem> pattern);

    void setStartCap(Cap startCap);

    void setVisible(boolean visible);

    void setWidth(float width);

    void setZIndex(float zIndex);
}
