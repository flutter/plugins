package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.Polygon;

import java.util.List;

/** Controller of a Polygons on the map. */
public class PolygonController implements PolygonOptionsSink {
    private final Polygon polygon;
    private final OnPolygonTappedListener onTappedListener;

    public PolygonController(Polygon polygon, OnPolygonTappedListener onTappedListener) {
        this.polygon = polygon;
        this.onTappedListener = onTappedListener;
    }

    void onTap() {
        if (onTappedListener != null) {
            onTappedListener.onPolygonTapped(polygon);
        }
    }

    void remove() {
        polygon.remove();
    }

    @Override
    public void setPoints(List<LatLng> points) {
        polygon.setPoints(points);
    }

    @Override
    public void setHoles(List<? extends List<LatLng>> holes) {
        polygon.setHoles(holes);
    }

    @Override
    public void setPattern(List<PatternItem> pattern) {
        polygon.setStrokePattern(pattern);
    }

    @Override
    public void setStrokeWidth(float strokeWidth) {
        polygon.setStrokeWidth(strokeWidth);
    }

    @Override
    public void setStrokeColor(int strokeColor) {
        polygon.setStrokeColor(strokeColor);
    }

    @Override
    public void setStrokeJointType(int strokeJointType) {
        polygon.setStrokeJointType(strokeJointType);
    }

    @Override
    public void setFillColor(int fillColor) {
        polygon.setFillColor(fillColor);
    }

    @Override
    public void setZIndex(float zIndex) {
        polygon.setZIndex(zIndex);
    }

    @Override
    public void setVisible(boolean visible) {
        polygon.setVisible(visible);
    }

    @Override
    public void setGeodesic(boolean geodesic) {
        polygon.setGeodesic(geodesic);
    }

    @Override
    public void setClickable(boolean clickable) {
        polygon.setClickable(clickable);
    }
}
