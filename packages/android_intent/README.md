# Android Intent Plugin for Flutter

---

## Deprecation Notice

This plugin has been replaced by the [Flutter Community Plus
Plugins](https://plus.fluttercommunity.dev/) version,
[`android_intent_plus`](https://pub.dev/packages/android_intent_plus).
No further updates are planned to this plugin, and we encourage all users to
migrate to the Plus version.

Critical fixes (e.g., for any security incidents) will be provided through the
end of 2021, at which point this package will be marked as discontinued.

---

This plugin allows Flutter apps to launch arbitrary intents when the platform
is Android. If the plugin is invoked on iOS, it will crash your app. In checked
mode, we assert that the platform should be Android.


Use it by specifying action, category, data and extra arguments for the intent.
It does not support returning the result of the launched activity. Sample usage:

```dart
if (Platform.isAndroid) {
  AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: 'https://play.google.com/store/apps/details?'
          'id=com.google.android.apps.myapp',
      arguments: {'authAccount': currentUserEmail},
  );
  await intent.launch();
}
```

See documentation on the AndroidIntent class for details on each parameter.

Action parameter can be any action including a custom class name to be invoked.
If a standard android action is required, the recommendation is to add support
for it in the plugin and use an action constant to refer to it. For instance:

`'action_view'` translates to `android.os.Intent.ACTION_VIEW`

`'action_location_source_settings'` translates to `android.settings.LOCATION_SOURCE_SETTINGS`

`'action_application_details_settings'` translates to `android.settings.ACTION_APPLICATION_DETAILS_SETTINGS`

```dart
if (Platform.isAndroid) {
  final AndroidIntent intent = AndroidIntent(
    action: 'action_application_details_settings',
    data: 'package:com.example.app', // replace com.example.app with your applicationId
  );
  await intent.launch();
}

```

Feel free to add support for additional Android intents.

The Dart values supported for the arguments parameter, and their corresponding
Android values, are listed [here](https://flutter.dev/docs/development/platform-integration/platform-channels#codec).
On the Android side, the arguments are used to populate an Android `Bundle`
instance. This process currently restricts the use of lists to homogeneous lists
of integers or strings.

> Note that a similar method does not currently exist for iOS. Instead, the
[url_launcher](https://pub.dev/packages/url_launcher) plugin
can be used for deep linking. Url launcher can also be used for creating
ACTION_VIEW intents for Android, however this intent plugin also allows
clients to set extra parameters for the intent.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).

For help on editing plugin code, view the [documentation](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin).
