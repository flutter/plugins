# Android Intent Plugin for Flutter

This plugin allows Flutter apps to launch arbitrary intents when the platform
is Android. If the plugin is invoked on iOS, it will crash your app. In checked
mode, we assert that the platform should be Android.

Use it by specifying action, category, data and extra arguments for the intent.
It does not support returning the result of the launched activity. Sample usage:

```dart
if (platform.isAndroid) {
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

Feel free to add support for additional Android intents.

The Dart values supported for the arguments parameter, and their corresponding
Android values, are listed [here](https://flutter.io/platform-channels/#codec).
On the Android side, the arguments are used to populate an Android `Bundle`
instance. This process currently restricts the use of lists to homogeneous lists
of integers or strings.

> Note that a similar method does not currently exist for iOS. Instead, the
[url_launcher](https://pub.dartlang.org/packages/url_launcher) plugin
can be used for deep linking. Url launcher can also be used for creating
ACTION_VIEW intents for Android, however this intent plugin also allows
clients to set extra parameters for the intent.

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
