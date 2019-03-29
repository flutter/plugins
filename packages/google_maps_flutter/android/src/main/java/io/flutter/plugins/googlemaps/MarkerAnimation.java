/* Copyright 2013 Google Inc.
   Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0.html */

package io.flutter.plugins.googlemaps;

import android.animation.ObjectAnimator;
import android.animation.TypeEvaluator;
import android.animation.ValueAnimator;
import android.annotation.TargetApi;
import android.os.Build;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Property;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.Interpolator;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;

public class MarkerAnimation {
    static private double getAngleDiff(double currentAngle, double targetAngle) {
        double diff = Math.abs(targetAngle - currentAngle);
        return Math.min(diff, 360 - diff);
    }
    static private double getRotateDir(double currentAngle, double targetAngle) {
        double abs_diff = getAngleDiff(currentAngle, targetAngle);
        if (abs_diff == 0) return 0;
        double clockwise_diff = Math.abs(targetAngle - (currentAngle + abs_diff) % 360);
        double anticlockwise_diff = Math.abs(targetAngle - (currentAngle - abs_diff + 360) % 360);
        if (clockwise_diff > anticlockwise_diff) return -1;
        return 1;
    }

    static private double toRad(double deg) {
        return deg * Math.PI / 180;
    }

    static private double toDeg(double rad) {
        return rad * 180 / Math.PI;
    }

    static private double getBearing(LatLng p1, LatLng p2) {
        double lat1 = toRad(p1.latitude);
        double lng1 = toRad(p1.longitude);
        double lat2 = toRad(p2.latitude);
        double lng2 = toRad(p2.longitude);
        double degree = toDeg(Math.atan2(Math.sin(lng2-lng1)*Math.cos(lat2), Math.cos(lat1)*Math.sin(lat2)-Math.sin(lat1)*Math.cos(lat2)*Math.cos(lng2-lng1)));
        if (degree >= 0) return degree;
        return degree + 360;
    }

    static void animateMarkerToGB(final Marker marker, final LatLng finalPosition, final LatLngInterpolator latLngInterpolator, final float durationInMs) {
        //System.out.println("GB:durationInMs " + Float.toString(durationInMs));
        final LatLng startPosition = marker.getPosition();
        final double startRotation = marker.getRotation();
        final double bearing = getBearing(startPosition, finalPosition);
        final double angle = getAngleDiff(startRotation, bearing);
        final double turn = getRotateDir(startRotation, bearing);
        final long start = SystemClock.uptimeMillis();
        final Interpolator interpolator = new AccelerateDecelerateInterpolator();
        final Interpolator interpolator2 = new AccelerateDecelerateInterpolator();
        final Handler handler = new Handler();
        final float fraction = 0.3f; // determine fraction of time for rotation -> (fraction) and translation -> (1 - fraction)

        handler.post(new Runnable() {
            long elapsed;
            float t;
            float v;

            @Override
            public void run() {
                // Calculate progress using interpolator
                elapsed = SystemClock.uptimeMillis() - start;
                t = elapsed / durationInMs / fraction;
                v = interpolator.getInterpolation(t);

                // Repeat till progress is complete.
                if (t < 1) {
                    // Post again 16ms later.
                    marker.setRotation((float)(startRotation + turn * v * angle));
                    handler.postDelayed(this, 16);
                }
            }
        });

        handler.postDelayed(new Runnable() {
            long elapsed;
            float t;
            float v;

            @Override
            public void run() {
                // Calculate progress using interpolator
                elapsed = SystemClock.uptimeMillis() - start - (long)(durationInMs * fraction);
                t = elapsed / durationInMs / (1 - fraction);
                v = interpolator.getInterpolation(t);

                // Repeat till progress is complete.
                if (t < 1) {
                    // Post again 16ms later.
                    marker.setPosition(latLngInterpolator.interpolate(v, startPosition, finalPosition));
                    handler.postDelayed(this, 16);
                }
            }
        }, (long)(durationInMs*fraction));
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    static void animateMarkerToHC(final Marker marker, final LatLng finalPosition, final LatLngInterpolator latLngInterpolator, final float durationInMs) {
        //System.out.println("HC:durationInMs " + Float.toString(durationInMs));
        final LatLng startPosition = marker.getPosition();
        final double startRotation = marker.getRotation();
        final double bearing = getBearing(startPosition, finalPosition);
        final double angle = getAngleDiff(startRotation, bearing);
        final double turn = getRotateDir(startRotation, bearing);

        ValueAnimator valueAnimator = new ValueAnimator();
        valueAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                float v = animation.getAnimatedFraction();
                LatLng newPosition = latLngInterpolator.interpolate(v, startPosition, finalPosition);
                marker.setRotation((float)(startRotation + turn * v * angle));
                marker.setPosition(newPosition);
            }
        });
        valueAnimator.setFloatValues(0, 1); // Ignored.
        valueAnimator.setDuration(Math.round(durationInMs));
        valueAnimator.start();
    }

    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    static void animateMarkerToICS(Marker marker, LatLng finalPosition, final LatLngInterpolator latLngInterpolator, final float durationInMs) {
        //System.out.println("ICS:durationInMs " + Float.toString(durationInMs));
        TypeEvaluator<LatLng> typeEvaluator = new TypeEvaluator<LatLng>() {
            @Override
            public LatLng evaluate(float fraction, LatLng startValue, LatLng endValue) {
                return latLngInterpolator.interpolate(fraction, startValue, endValue);
            }
        };
        Property<Marker, LatLng> property = Property.of(Marker.class, LatLng.class, "position");
        ObjectAnimator animator = ObjectAnimator.ofObject(marker, property, typeEvaluator, finalPosition);
        animator.setDuration(Math.round(durationInMs));
        animator.start();
    }
}