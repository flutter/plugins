# quick_actions

This Flutter plugin allows you to manage and interact with the application's
home screen quick actions.

Quick actions refer to the [eponymous
concept](https://developer.apple.com/design/human-interface-guidelines/ios/system-capabilities/home-screen-actions/)
on iOS and to the [App
Shortcuts](https://developer.android.com/guide/topics/ui/shortcuts.html) APIs on
Android (introduced in Android 7.1 / API level 25). It is safe to run this plugin
with earlier versions of Android as it will produce a noop.

## Usage in Dart

Initialize the library early in your application's lifecycle by providing a
callback, which will then be called whenever the user launches the app via a
quick action.

```dart
final QuickActions quickActions = const QuickActions();
quickActions.initialize((shortcutType) {
  if (shortcutType == 'action_main') {
    print('The user tapped on the "Main view" action.');
  }
  // More handling code...
});
```

Finally, manage the app's quick actions, for instance:

```dart
quickActions.setShortcutItems(<ShortcutItem>[
  const ShortcutItem(type: 'action_main', localizedTitle: 'Main view', icon: 'icon_main'),
  const ShortcutItem(type: 'action_help', localizedTitle: 'Help', icon: 'icon_help')
]);
```

Please note, that the `type` argument should be unique within your application
(among all the registered shortcut items). The optional `icon` should be the
name of the native resource (xcassets on iOS or drawable on Android) that the app will display for the
quick action.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).

For help on editing plugin code, view the [documentation](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin).
