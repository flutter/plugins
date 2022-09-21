## NEXT

* Updates minimum Flutter version to 2.10.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.9.0

* **BREAKING CHANGE**: Methods that take `XTypeGroup`s now throw an
  `ArgumentError` if any group is not a wildcard (all filter types null or
  empty), but doesn't include any of the filter types supported by web.

## 0.8.1+5

* Minor fixes for new analysis options.

## 0.8.1+4

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.1+3

* Minor code cleanup for new analysis rules.
* Removes dependency on `meta`.

## 0.8.1+2

* Add `implements` to pubspec.

# 0.8.1+1

- Updated installation instructions in README.

# 0.8.1

- Return a non-null value from `getSavePath` for consistency with
  API expectations that null indicates canceling.

# 0.8.0

- Migrated to null-safety

# 0.7.0+1

- Add dummy `ios` dir, so flutter sdk can be lower than 1.20

# 0.7.0

- Initial open-source release.
