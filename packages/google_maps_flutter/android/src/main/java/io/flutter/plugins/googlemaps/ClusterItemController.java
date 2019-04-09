package io.flutter.plugins.googlemaps;
import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.ClusterItem;

public class ClusterItemController implements ClusterItem {
    private final LatLng mPosition;
    private final String mTitle;
    private final String mSnippet;
    private final String googleMapsClusterItemId;

    public ClusterItemController(double lat, double lng, String clusterItemId) {
        mPosition = new LatLng(lat, lng);
        mTitle = "";
        mSnippet = "";
        this.googleMapsClusterItemId =clusterItemId;
    }

    public ClusterItemController(double lat, double lng, String title, String snippet, String clusterItemId) {
        mPosition = new LatLng(lat, lng);
        mTitle = title;
        mSnippet = snippet;
        this.googleMapsClusterItemId =clusterItemId;
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
}