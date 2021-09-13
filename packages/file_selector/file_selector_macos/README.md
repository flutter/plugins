# file\_selector\_macos

The macOS implementation of [`file_selector`][1].

## Usage

### Importing the package

This implementation has not yet been endorsed, meaning that you need to
[depend on `file_selector_macos`][2] in addition to
[depending on `file_selector`][3].

Once your pubspec includes the macOS implementation, you can use the
`file_selector` APIs normally. You should not use the `file_selector_macos`
APIs directly.

### Entitlements

You will need to [add an entitlement][4] for either read-only access:
```
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
```
or read/write access:
```
	<key>com.apple.security.files.user-selected.read-write</key>
	<true/>
```
depending on your use case.

[1]: https://pub.dev/packages/file_selector
[2]: https://pub.dev/packages/file_selector_macos/install
[3]: https://pub.dev/packages/file_selector/install
[4]: https://flutter.dev/desktop#entitlements-and-the-app-sandbox
