## 0.9.2+2

* Adds `getDirectoryPaths` method.

## 0.9.2+1

* Improves API docs and examples.
* Changes XTypeGroup initialization from final to const.
* Updates minimum Flutter version to 2.10.

## 0.9.2

* Adds an endorsed iOS implementation.

## 0.9.1

* Adds an endorsed Linux implementation.

## 0.9.0

* **BREAKING CHANGE**: The following methods:
    * `openFile`
    * `openFiles`
    * `getSavePath`

  can throw `ArgumentError`s if called with any `XTypeGroup`s that
  do not contain appropriate filters for the current platform. For
  example, an `XTypeGroup` that only specifies `webWildCards` will
  throw on non-web platforms.

  To avoid runtime errors, ensure that all `XTypeGroup`s (other than
  wildcards) set filters that cover every platform your application
  targets. See the README for details.

## 0.8.4+3

* Improves API docs and examples.
* Minor fixes for new analysis options.

## 0.8.4+2

* Removes unnecessary imports.
* Adds OS version support information to README.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.4+1

* Adds README information about macOS entitlements.
* Adds necessary entitlement to macOS example.

## 0.8.4

* Adds an endorsed macOS implementation.

## 0.8.3

* Adds an endorsed Windows implementation.

## 0.8.2+1

* Minor code cleanup for new analysis rules.
* Updated package description.

## 0.8.2

* Update `platform_plugin_interface` version requirement.

## 0.8.1

Endorse the web implementation.

## 0.8.0

Migrate to null safety.

## 0.7.0+2

* Update the example app: remove the deprecated `RaisedButton` and `FlatButton` widgets.

## 0.7.0+1

* Update Flutter SDK constraint.

## 0.7.0

* Initial Open Source release.
