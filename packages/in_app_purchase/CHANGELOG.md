## 0.1.0

Beta relase.

* Ability to list products, load previous purchases, and make purchases.
* Simplified Dart API that's been unified as much as possible for ease of use.
* Platform specific APIs more directly exposing `StoreKit` and `BillingClient`.

Changes:

* [in_app_purchase] Remove extraneous download logic (#1560)
* [in_app_purchase] Minor doc updates (#1555)
* [in_app_purchase] Only fetch owned purchases (#1540)
* [in_app_purchase] Add auto-consume errors to PurchaseDetails (#1537)
* [in_app_purchase] Minor doc updates (#1536)
* [in_app_purchase] Rename the unified API (#1517)
* [in_app_purchase]remove SKDownloadWrapper and related code. (#1474)
* [in_app_purchase]make payment unified APIs (#1421)
* [in_app_purchase] Add references to the original object for PurchaseDetails and ProductDetails (#1448)
* [in_app_purchase]load purchase (#1380)
* [in_app_purchase] Iap refactor (#1381)
* add driver test command to cirrus (#1342)
* [in_app_purchase] refactoring and tests (#1322)
* [in_app_purchase] Adds Dart BillingClient APIs for loading purchases (#1286)
* [in_app_purchase]retrieve receipt (#1303)
* [in_app_purchase]restore purchases (#1299)
* [in_app_purchase] payment queue dart ios (#1249)
* [in_app_purchase] Minor bugfixes and code cleanup (#1284)
* [in_app_purchase] Fix CI formatting errors. (#1281)
* [in_app_purchase] Java API for querying purchases (#1259)
* [In_app_purchase]SKProduct related fixes (#1252)
* IAP make payment objc (#1231)
* [IAP] Add the Dart API for launchBillingFlow (#1232)
* [IAP] Add Java call for launchBillingFlow (#1230)
* [In_app_purchase]remove categories (#1222)
* [In_app_purchase]fix requesthandler crash (#1199)
* Iap getproductlist basic draft (#1169)
* Iap iOS add payment dart wrappers (#1178)
* Fix the param map passed down to the platform channel when calling querySkuDetails (#1194)
* Mark some packages as unpublishable (#1193)
* Add a gradle warning to the AndroidX plugins (#1138)
* Iap add payment objc translators (#1172)
* Revert "IAP add payment translators in objc (#1126)" (#1171)
* IAP add payment translators in objc (#1126)
* Expose nslocale and expose currencySymbol instead of currencyCode to match android (#1162)
* Using json serializer for skproduct wrapper and related classes (#1147)
* Iap productlist ios (#1068)
* [IAP] Update dev deps to match flutter_driver (#1118)
* [IAP] Update README (#1112)
* Migrate independent plugins to AndroidX (#1103)
* [IAP] Generate boilerplate serializers (#1090)
* [IAP] Fetch SkuDetails from Google Play (#1084)
* [IAP] Add missing license headers (#1083)
* [IAP] Clean up Dart unit tests (#1082)
* [IAP] Check if the payment processor is available (#1057)
* Fix `Manifest versionCode not found` (#1076)
* Supress `strong_mode_implicit_dynamic_method` for `invokeMethod` calls. (#1065)
* Doc and build script updates to the IAP plugin (#1024)
* Update the IAP README (#933)
* Upgrade Android Gradle Plugin to 3.2.1 (#916)
* Set all gradle-wrapper versions to 4.10.2 (#915)
* Reconfigure Cirrus to use clang 7 (#905)
* Update gradle dependencies. (#881)
* Enable lint unnecessary_new (#701)

## 0.0.2

* Added missing flutter_test package dependency.
* Added missing flutter version requirements.

## 0.0.1

* Initial release.
