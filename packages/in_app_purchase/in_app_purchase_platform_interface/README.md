# in_app_purchase_platform_interface

A common platform interface for the [`in_app_purchase`][1] plugin.

This interface allows platform-specific implementations of the `in_app_purchase`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `in_app_purchase`, extend
[`InAppPurchasePlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`InAppPurchasePlatform` by calling
`InAppPurchasePlatform.setInstance(MyPlatformInAppPurchase())`.

To implement functionality that is specific to the platform and is not covered 
by the [`InAppPurchasePlatform`][2] idiomatic API, extend 
[`InAppPurchasePlatformAddition`][3] with the platform-specific functionality, 
and when the plugin is registered, set the addition instance by calling
`InAppPurchasePlatformAddition.instance = MyPlatformInAppPurchaseAddition()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../in_app_purchase
[2]: lib/in_app_purchase_platform_interface.dart
[3]: lib/in_app_purchase_platform_addition.dart