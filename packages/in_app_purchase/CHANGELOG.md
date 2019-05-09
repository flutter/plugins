## 0.1.0+1

Add more consumable handling to the example app.

## 0.1.0

Beta relase.

* Ability to list products, load previous purchases, and make purchases.
* Simplified Dart API that's been unified for ease of use.
* Platform specific APIs more directly exposing `StoreKit` and `BillingClient`.

Includes:

* 5ba657dc [in_app_purchase] Remove extraneous download logic (#1560)
* 01bb8796 [in_app_purchase] Minor doc updates (#1555)
* 1a4d493f [in_app_purchase] Only fetch owned purchases (#1540)
* d63c51cf [in_app_purchase] Add auto-consume errors to PurchaseDetails (#1537)
* 959da97f [in_app_purchase] Minor doc updates (#1536)
* b82ae1a6 [in_app_purchase] Rename the unified API (#1517)
* d1ad723a [in_app_purchase]remove SKDownloadWrapper and related code. (#1474)
* 7c1e8b8a [in_app_purchase]make payment unified APIs (#1421)
* 80233db6 [in_app_purchase] Add references to the original object for PurchaseDetails and ProductDetails (#1448)
* 8c180f0d [in_app_purchase]load purchase (#1380)
* e9f141bc [in_app_purchase] Iap refactor (#1381)
* d3b3d60c add driver test command to cirrus (#1342)
* aee12523 [in_app_purchase] refactoring and tests (#1322)
* 6d7b4592 [in_app_purchase] Adds Dart BillingClient APIs for loading purchases (#1286)
* 5567a9c8 [in_app_purchase]retrieve receipt (#1303)
* 3475f1b7 [in_app_purchase]restore purchases (#1299)
* a533148d [in_app_purchase] payment queue dart ios (#1249)
* 10030840 [in_app_purchase] Minor bugfixes and code cleanup (#1284)
* 347f508d [in_app_purchase] Fix CI formatting errors. (#1281)
* fad02d87 [in_app_purchase] Java API for querying purchases (#1259)
* bc501915 [In_app_purchase]SKProduct related fixes (#1252)
* f92ba3a1 IAP make payment objc (#1231)
* 62b82522 [IAP] Add the Dart API for launchBillingFlow (#1232)
* b40a4acf [IAP] Add Java call for launchBillingFlow (#1230)
* 4ff06cd1 [In_app_purchase]remove categories (#1222)
* 0e72ca56 [In_app_purchase]fix requesthandler crash (#1199)
* 81dff2be Iap getproductlist basic draft (#1169)
* db139b28 Iap iOS add payment dart wrappers (#1178)
* 2e5fbb9b Fix the param map passed down to the platform channel when calling querySkuDetails (#1194)
* 4a84bac1 Mark some packages as unpublishable (#1193)
* 51696552 Add a gradle warning to the AndroidX plugins (#1138)
* 832ab832 Iap add payment objc translators (#1172)
* d0e615cf Revert "IAP add payment translators in objc (#1126)" (#1171)
* 09a5a36e IAP add payment translators in objc (#1126)
* a100fbf9 Expose nslocale and expose currencySymbol instead of currencyCode to match android (#1162)
* 1c982efd Using json serializer for skproduct wrapper and related classes (#1147)
* 3039a261 Iap productlist ios (#1068)
* 2a1593da [IAP] Update dev deps to match flutter_driver (#1118)
* 9f87cbe5 [IAP] Update README (#1112)
* 59e84d85 Migrate independent plugins to AndroidX (#1103)
* a027ccd6 [IAP] Generate boilerplate serializers (#1090)
* 909cf1c2 [IAP] Fetch SkuDetails from Google Play (#1084)
* 6bbaa7e5 [IAP] Add missing license headers (#1083)
* 5347e877 [IAP] Clean up Dart unit tests (#1082)
* fe03e407 [IAP] Check if the payment processor is available (#1057)
* 43ee28cf Fix `Manifest versionCode not found` (#1076)
* 4d702ad7 Supress `strong_mode_implicit_dynamic_method` for `invokeMethod` calls. (#1065)
* 809ccde7 Doc and build script updates to the IAP plugin (#1024)
* 052b71a9 Update the IAP README (#933)
* 54f9c4e2 Upgrade Android Gradle Plugin to 3.2.1 (#916)
* ced3e99d Set all gradle-wrapper versions to 4.10.2 (#915)
* eaa1388b Reconfigure Cirrus to use clang 7 (#905)
* 9b153920 Update gradle dependencies. (#881)
* 1aef7d92 Enable lint unnecessary_new (#701)

## 0.0.2

* Added missing flutter_test package dependency.
* Added missing flutter version requirements.

## 0.0.1

* Initial release.
