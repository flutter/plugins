/* Copyright 2019 HKTaxiApp.
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
   import android.view.animation.LinearInterpolator;
   import android.view.animation.Interpolator;
   
   import com.google.android.gms.maps.model.LatLng;
   import com.google.android.gms.maps.model.Marker;

   import java.util.List;
   
   public class RouteAnimation {
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

       static private class RotationRunnable implements Runnable {
           private final Marker marker;
           private final Handler handler;
           private final long start;
           private final float durationWithinRoute;
           private final Interpolator interpolator;
           private final float fraction;
           private final double startRotation;
           private final double turn;
           private final double angle;

           public RotationRunnable(Marker marker, Handler handler, long start, float durationWithinRoute, Interpolator interpolator, float fraction, double startRotation, double turn, double angle) {
               this.marker = marker;
               this.handler = handler;
               this.start = start;
               this.durationWithinRoute = durationWithinRoute;
               this.interpolator = interpolator;
               this.fraction = fraction;
               this.startRotation = startRotation;
               this.turn = turn;
               this.angle = angle;
           }

           private static long elapsed;
           private static float t;
           private static float v;

           @Override
           public void run() {
               // Calculate progress using interpolator
               elapsed = SystemClock.uptimeMillis() - start;
               t = elapsed / durationWithinRoute / fraction;
               v = interpolator.getInterpolation(t);

               // Repeat till progress is complete.
               if (t < 1) {
                   // Post again 10ms later.
                   marker.setRotation((float)(startRotation + turn * v * angle));
                   handler.postDelayed(this, 10);
               }
            }
       }

       static private class TranslationRunnable implements Runnable {
           private final Marker marker;
           private final LatLngInterpolator latLngInterpolator;
           private final Handler handler;
           private final long start;
           private final float durationWithinRoute;
           private final Interpolator interpolator;
           private final float fraction;
           private final LatLng startPosition;
           private final LatLng finalPosition;

           public TranslationRunnable(Marker marker, LatLngInterpolator latLngInterpolator, Handler handler, long start, float durationWithinRoute, Interpolator interpolator, float fraction, LatLng startPosition, LatLng finalPosition) {
               this.marker = marker;
               this.latLngInterpolator = latLngInterpolator;
               this.handler = handler;
               this.start = start;
               this.durationWithinRoute = durationWithinRoute;
               this.interpolator = interpolator;
               this.fraction = fraction;
               this.startPosition = startPosition;
               this.finalPosition = finalPosition;
           }

           private static long elapsed;
           private static float t;
           private static float v;

           @Override
           public void run() {
               // Calculate progress using interpolator
               elapsed = SystemClock.uptimeMillis() - start - (long)(durationWithinRoute * fraction);
               t = elapsed / durationWithinRoute / (1 - fraction);
               v = interpolator.getInterpolation(t);

               // Repeat till progress is complete.
               if (t < 1) {
                   // Post again 10ms later.
                   marker.setPosition(latLngInterpolator.interpolate(v, startPosition, finalPosition));
                   handler.postDelayed(this, 10);
               }
           }
       }

       static private class RotationAndTranslationRunnable implements Runnable {
           private final Marker marker;
           private final LatLngInterpolator latLngInterpolator;
           private final Handler handler;
           private final long start;
           private final float durationWithinRoute;
           private final Interpolator interpolator;
           private final LatLng startPosition;
           private final LatLng finalPosition;
           private final double startRotation;
           private final double turn;
           private final double angle;
           
           public RotationAndTranslationRunnable(Marker marker, LatLngInterpolator latLngInterpolator, Handler handler, long start, float durationWithinRoute, Interpolator interpolator, LatLng startPosition, LatLng finalPosition, double startRotation, double turn, double angle) {
               this.marker = marker;
               this.latLngInterpolator = latLngInterpolator;
               this.handler = handler;
               this.start = start;
               this.durationWithinRoute = durationWithinRoute;
               this.interpolator = interpolator;
               this.startPosition = startPosition;
               this.finalPosition = finalPosition;
               this.startRotation = startRotation;
               this.turn = turn;
               this.angle = angle;
           }

           private static long elapsed;
           private static float t;
           private static float v;

           @Override
           public void run() {
               // Calculate progress using interpolator
               elapsed = SystemClock.uptimeMillis() - start;
               t = elapsed / durationWithinRoute;
               v = interpolator.getInterpolation(t);

               // Repeat till progress is complete.
               if (t < 1) {
                   // Post again 10ms later.
                   marker.setRotation((float)(startRotation + turn * v * angle));
                   marker.setPosition(latLngInterpolator.interpolate(v, startPosition, finalPosition));
                   handler.postDelayed(this, 10);
               }
           }
       }
   
       static void animateMarkerToGB(final Marker marker, final List<LatLng> route, final LatLngInterpolator latLngInterpolator, final float durationInMs, boolean rotateThenTranslate) {
           final int numberOfPositions = route.size();
           final float durationWithinRoute = durationInMs / numberOfPositions;

           final long now = SystemClock.uptimeMillis();
           final float fraction = 0.3f; // determine fraction of time for rotation -> (fraction) and translation -> (1 - fraction)

           LatLng prevPosition = marker.getPosition();
           double prevRotation = marker.getRotation();
   
           for (int i = 0; i < numberOfPositions; i++) {
                LatLng curPosition = route.get(i);
                double bearing = getBearing(prevPosition, curPosition);
                double angle = getAngleDiff(prevRotation, bearing);
                double turn = getRotateDir(prevRotation, bearing);
                long start = now + (long)(durationWithinRoute * i);
                if (rotateThenTranslate) {
                    Handler handler1 = new Handler();
                    Handler handler2 = new Handler();
                    Interpolator interpolator1 = new LinearInterpolator();
                    Interpolator interpolator2 = new LinearInterpolator();
                    RotationRunnable rr = new RotationRunnable(marker, handler1, start, durationWithinRoute, interpolator1, fraction, prevRotation, turn, angle);
                    TranslationRunnable tr = new TranslationRunnable(marker, latLngInterpolator, handler2, start+(long)(durationWithinRoute*i), durationWithinRoute, interpolator2, fraction, prevPosition, curPosition);
                    handler1.postDelayed(rr, (long)(durationWithinRoute*i));
                    handler2.postDelayed(tr, (long)(durationWithinRoute*i+durationWithinRoute*fraction));
                } else {
                    Handler handler = new Handler();
                    Interpolator interpolator = new LinearInterpolator();
                    RotationAndTranslationRunnable ratr = new RotationAndTranslationRunnable(marker, latLngInterpolator, handler, start, durationWithinRoute, interpolator, prevPosition, curPosition, prevRotation, turn, angle);
                    handler.postDelayed(ratr, (long)(durationWithinRoute*i));
                }
                prevPosition = curPosition;
                prevRotation += turn * angle;
                if (prevRotation < 0) prevRotation += 360;
                else if (prevRotation > 360) prevRotation -= 360;
            }
       }
   
       @TargetApi(Build.VERSION_CODES.HONEYCOMB)
       static void animateMarkerToHC(final Marker marker, final List<LatLng> route, final LatLngInterpolator latLngInterpolator, final float durationInMs, boolean rotateThenTranslate) {
           final int numberOfPositions = route.size();
           final float durationWithinRoute = durationInMs / numberOfPositions;

           for (int i = 0; i < numberOfPositions; i++) {
               final LatLng startPosition = marker.getPosition();
               final double startRotation = marker.getRotation();
               final LatLng finalPosition = route.get(i);
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
                valueAnimator.setDuration((long)(Math.floor(durationWithinRoute)));
                valueAnimator.setStartDelay((long)(Math.floor(durationWithinRoute)*i));
                valueAnimator.start();
            }
       }
   
       @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
       static void animateMarkerToICS(Marker marker, List<LatLng> route, final LatLngInterpolator latLngInterpolator, final float durationInMs, boolean rotateThenTranslate) {
           final int numberOfPositions = route.size();
           final float durationWithinRoute = durationInMs / numberOfPositions;

           for (int i = 0; i < numberOfPositions; i++) {
               final LatLng finalPosition = route.get(i);
               TypeEvaluator<LatLng> typeEvaluator = new TypeEvaluator<LatLng>() {
                   @Override
                   public LatLng evaluate(float fraction, LatLng startValue, LatLng endValue) {
                       return latLngInterpolator.interpolate(fraction, startValue, endValue);
                    }
                };
                Property<Marker, LatLng> property = Property.of(Marker.class, LatLng.class, "position");
                ObjectAnimator animator = ObjectAnimator.ofObject(marker, property, typeEvaluator, finalPosition);
                animator.setDuration((long)(Math.round(durationWithinRoute)));
                animator.setStartDelay((long)(Math.round(durationWithinRoute)*i));
                animator.start();
            }
       }
   }