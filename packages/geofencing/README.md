# Geofencing

A sample geofencing plugin with background execution support for Flutter.

## Getting Started
This plugin works on both Android and iOS. Follow the instructions in the following sections for the
platforms which are to be targeted.

### Android

Add the following lines to your `AndroidManifest.xml` to register the background service for
geofencing:

```xml
<receiver android:name="io.flutter.plugins.geofencing.GeofencingBroadcastReceiver"
    android:enabled="true" android:exported="true"/>
<service android:name="io.flutter.plugins.geofencing.GeofencingService"
    android:permission="android.permission.BIND_JOB_SERVICE" android:exported="true"/>
```

Also request the correct permissions for geofencing:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

Finally, create either `Application.kt` or `Application.java` in the same directory as `MainActivity`.
 
For `Application.kt`, use the following:

```kotlin
class Application : FlutterApplication(), PluginRegistrantCallback {
  override fun onCreate() {
    super.onCreate();
    GeofencingService.setPluginRegistrant(this);
  }

  override fun registerWith(registry: PluginRegistry) {
    GeneratedPluginRegistrant.registerWith(registry);
  }
}
```

For `Application.java`, use the following:

```java
public class Application extends FlutterApplication implements PluginRegistrantCallback {
  @Override
  public void onCreate() {
    super.onCreate();
    GeofencingService.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry) {
    GeneratedPluginRegistrant.registerWith(registry);
  }
}
```

Which must also be referenced in `AndroidManifest.xml`:

```xml
    <application
        android:name=".Application"
        ...
```
 
### iOS

Add the following lines to your Info.plist:

```xml
<dict>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>YOUR DESCRIPTION HERE</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>YOUR DESCRIPTION HERE</string>
    ...
```

And request the correct permissions for geofencing:

```xml
<dict>
    ...
    <string>Main</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>location-services</string>
        <string>gps</string>
        <string>armv7</string>
    </array>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
    </array>
    ...
</dict>
```

### Need Help?

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).
