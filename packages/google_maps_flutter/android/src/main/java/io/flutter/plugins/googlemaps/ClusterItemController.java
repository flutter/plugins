package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.ClusterItem;

public class ClusterItemController implements ClusterItem {
    private final LatLng mPosition;
    private final String mTitle;
    private final String mSnippet;
    private final String googleMapsClusterItemId;
    private boolean consumeTapEvents;
    private final BitmapDescriptor bitmapDescriptor;

    public ClusterItemController(double lat, double lng, String clusterItemId, boolean consumeTapEvents,
            BitmapDescriptor bitmapDescriptor) {
        mPosition = new LatLng(lat, lng);
        mTitle = "";
        mSnippet = "";
        this.googleMapsClusterItemId = clusterItemId;
        this.consumeTapEvents = consumeTapEvents;
        this.bitmapDescriptor = bitmapDescriptor;
    }

    public ClusterItemController(double lat, double lng, String title, String snippet, String clusterItemId,
            boolean consumeTapEvents, BitmapDescriptor bitmapDescriptor) {
        mPosition = new LatLng(lat, lng);
        mTitle = title;
        mSnippet = snippet;
        this.googleMapsClusterItemId = clusterItemId;
        this.consumeTapEvents = consumeTapEvents;
        this.bitmapDescriptor = bitmapDescriptor;
    }

    @Override
    public LatLng getPosition() {
        return mPosition;
    }

    @Override
    public String getTitle() {
        return mTitle;
    }

    @Override
    public String getSnippet() {
        return mSnippet;
    }

    String getGoogleMapsClusterItemId() {
        return googleMapsClusterItemId;
    }

    public void setConsumeTapEvents(boolean consumeTapEvents) {
        this.consumeTapEvents = consumeTapEvents;
    }

    boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    public BitmapDescriptor getIcon() {
        return this.bitmapDescriptor;
    }

}