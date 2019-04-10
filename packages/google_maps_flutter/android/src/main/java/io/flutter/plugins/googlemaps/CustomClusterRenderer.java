package io.flutter.plugins.googlemaps;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.clustering.view.DefaultClusterRenderer;

public class CustomClusterRenderer extends DefaultClusterRenderer<ClusterItemController> {
    private final Context mContext;

    public CustomClusterRenderer(Context context, GoogleMap map, ClusterManager<ClusterItemController> clusterManager) {
        super(context, map, clusterManager);
        mContext = context;
    }

    @Override
    protected void onBeforeClusterItemRendered(ClusterItemController item, MarkerOptions markerOptions) {
        markerOptions.icon(item.getIcon()).snippet(item.getTitle());
    }
}