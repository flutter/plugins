package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;

import org.junit.Assert;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

public class ConvertTest{

    @Test
    public void toPointsConvertsThePointsWithFullPrecision(){
            double latitude = 43.03725568057;
            double longitude = -87.90466904649;
        ArrayList<Double> point = new ArrayList<Double>();
        point.add(latitude);
        point.add(longitude);
        ArrayList<ArrayList<Double>> pointsList = new ArrayList<>();
        pointsList.add(point);
        List<LatLng> latLngs = Convert.toPoints(pointsList);
        LatLng latLng = latLngs.get(0);
        Assert.assertEquals(String.valueOf(latitude), String.valueOf(latLng.latitude));
        Assert.assertEquals(String.valueOf(longitude), String.valueOf(latLng.longitude));

    }
}