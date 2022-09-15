## 0.10.0+2

* Removes call to `join` on the camera's background `HandlerThread`.
* Updates minimum Flutter version to 2.10.

## 0.10.0+1

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.10.0

* **Breaking Change** Updates Android camera access permission error codes to be consistent with other platforms. If your app still handles the legacy `cameraPermission` exception, please update it to handle the new permission exception codes that are noted in the README.
* Ignores missing return warnings in preparation for [upcoming analysis changes](https://github.com/flutter/flutter/issues/105750).

## 0.9.8+3

* Skips duplicate calls to stop background thread and removes unnecessary closings of camera capture sessions on Android.

## 0.9.8+2

* Fixes exception in registerWith caused by the switch to an in-package method channel.

## 0.9.8+1

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.9.8

* Switches to internal method channel implementation.

## 0.9.7+1

* Splits from `camera` as a federated implementation.
