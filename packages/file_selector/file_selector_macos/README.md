# file\_selector\_macos

The macOS implementation of [`file_selector`][1].

## Usage

This package is [endorsed][2], which means you can simply use `file_selector`
normally. This package will be automatically included in your app when you do.

### Entitlements

You will need to [add an entitlement][3] for either read-only access:
```xml
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
```
or read/write access:
```xml
	<key>com.apple.security.files.user-selected.read-write</key>
	<true/>
```
depending on your use case.

[1]: https://pub.dev/packages/file_selector
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://flutter.dev/desktop#entitlements-and-the-app-sandbox
