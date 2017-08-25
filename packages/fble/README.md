# fble

A Flutter plugin for Bluetooth Low Energy.

This plugin allows Flutter mobile apps to scan for peripheral devices and
receive advertisement packets.

Bi-directional communication is planned but has not been implemented yet.

## Usage

To use this plugin, add `fble` as a dependency in your `pubspec.yaml` file.

The first step is to call `Fble.localAdapters` to obtain a list of all
Bluetooth adapters on the device. There is often only one device returned.

Then call `adapter.startScan` with appropriate filters to initiate the scan.
The method `startScan` returns a `Stream<ScanResult>`. Subscribe to this
stream to receive advertisements.

See [example/lib/main.dart](example/lib/main.dart) for a demo.
