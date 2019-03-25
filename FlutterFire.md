# FlutterFire

FlutterFire is a set of [Flutter plugins](https://flutter.io/platform-plugins/)
that enable Flutter apps to use one or more [Firebase](https://firebase.google.com/) services. You can follow an example that shows how to use these plugins in the [Firebase for Flutter](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#0) codelab.

[Flutter](https://flutter.io) is a new mobile app SDK to help developers and
designers build modern mobile apps for iOS and Android.
  
*Note*: These plugins are part of the [Flutter open source project](https://github.com/flutter). 
The plugins are still under development, and some APIs might not be available yet. 
[Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!
 
## Available FlutterFire plugins

| Plugin | Version | Firebase feature | Source code |
|---|---|---|---|
| [cloud_firestore][firestore_pub] | ![pub package][firestore_badge] | [Cloud Firestore][firestore_product] | [`packages/cloud_firestore`][firestore_code] |
| [cloud_functions][functions_pub] | ![pub package][functions_badge] | [Cloud Functions][functions_product] | [`packages/cloud_functions`][functions_code] |
| [firebase_admob][admob_pub] | ![pub package][admob_badge] | [Firebase AdMob][admob_product] | [`packages/firebase_admob`][admob_code] |
| [firebase_analytics][analytics_pub] | ![pub package][analytics_badge] | [Firebase Analytics][analytics_product] | [`packages/firebase_analytics`][analytics_code] |
| [firebase_auth][auth_pub] | ![pub package][auth_badge] | [Firebase Authentication][auth_product] | [`packages/firebase_auth`][auth_code] |
| [firebase_core][core_pub] | ![pub package][core_badge] | [Firebase Core][core_product] | [`packages/firebase_core`][core_code] |
| [firebase_crashlytics][crash_pub] | ![pub package][crash_badge] | [Firebase Crashlytics][crash_product] | [`packages/firebase_crashlytics`][crash_code] |
| [firebase_database][database_pub] | ![pub package][database_badge] | [Firebase Realtime Database][database_product] | [`packages/firebase_database`][database_code] |
| [firebase_dynamic_links][dynamic_links_pub] | ![pub package][dynamic_links_badge] | [Firebase Dynamic Links][dynamic_links_product] | [`packages/firebase_dynamic_links`][dynamic_links_code] |
| [firebase_messaging][messaging_pub] | ![pub package][messaging_badge] | [Firebase Cloud Messaging][messaging_product] | [`packages/firebase_messaging`][messaging_code] |
| [firebase_ml_vision][ml_vision_pub] | ![pub package][ml_vision_badge] | [Firebase ML Kit][ml_vision_product] | [`packages/firebase_ml_vision`][ml_vision_code] |
| [firebase_performance][performance_pub] | ![pub package][performance_badge] | [Firebase Performance Monitoring][performance_product] | [`packages/firebase_performance`][performance_code] |
| [firebase_remote_config][remote_config_pub] | ![pub package][remote_config_badge] | [Firebase Remote Config][remote_config_product] | [`packages/firebase_remote_config`][remote_config_code] |
| [firebase_storage][storage_pub] | ![pub package][storage_badge] | [Firebase Cloud Storage][storage_product] | [`packages/firebase_storage`][storage_code] |

[admob_pub]: https://pub.dartlang.org/packages/firebase_admob
[admob_product]: https://firebase.google.com/docs/admob/
[admob_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_admob
[admob_badge]: https://img.shields.io/pub/v/firebase_admob.svg

[analytics_pub]: https://pub.dartlang.org/packages/firebase_analytics
[analytics_product]: https://firebase.google.com/products/analytics/
[analytics_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_analytics
[analytics_badge]: https://img.shields.io/pub/v/firebase_analytics.svg

[auth_pub]: https://pub.dartlang.org/packages/firebase_auth
[auth_product]: https://firebase.google.com/products/auth/
[auth_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_auth
[auth_badge]: https://img.shields.io/pub/v/firebase_auth.svg

[core_pub]: https://pub.dartlang.org/packages/firebase_core
[core_product]: https://firebase.google.com/
[core_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_core
[core_badge]: https://img.shields.io/pub/v/firebase_core.svg

[crash_pub]: https://pub.dartlang.org/packages/firebase_crashlytics
[crash_product]: https://firebase.google.com/products/crashlytics/
[crash_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_crashlytics
[crash_badge]: https://img.shields.io/pub/v/firebase_crashlytics.svg

[database_pub]: https://pub.dartlang.org/packages/firebase_database
[database_product]: https://firebase.google.com/products/database/
[database_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_database
[database_badge]: https://img.shields.io/pub/v/firebase_database.svg

[dynamic_links_pub]: https://pub.dartlang.org/packages/firebase_dynamic_links
[dynamic_links_product]: https://firebase.google.com/products/dynamic-links/
[dynamic_links_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_dynamic_links
[dynamic_links_badge]: https://img.shields.io/pub/v/firebase_dynamic_links.svg

[firestore_pub]: https://pub.dartlang.org/packages/cloud_firestore
[firestore_product]: https://firebase.google.com/products/firestore/
[firestore_code]: https://github.com/flutter/plugins/tree/master/packages/cloud_firestore
[firestore_badge]: https://img.shields.io/pub/v/cloud_firestore.svg

[functions_pub]: https://pub.dartlang.org/packages/cloud_functions
[functions_product]: https://firebase.google.com/products/functions/
[functions_code]: https://github.com/flutter/plugins/tree/master/packages/cloud_functions
[functions_badge]: https://img.shields.io/pub/v/cloud_functions.svg

[messaging_pub]: https://pub.dartlang.org/packages/firebase_messaging
[messaging_product]: https://firebase.google.com/products/cloud-messaging/
[messaging_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_messaging
[messaging_badge]: https://img.shields.io/pub/v/firebase_messaging.svg

[ml_vision_pub]: https://pub.dartlang.org/packages/firebase_ml_vision
[ml_vision_product]: https://firebase.google.com/products/ml-kit/
[ml_vision_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_ml_vision
[ml_vision_badge]: https://img.shields.io/pub/v/firebase_ml_vision.svg

[performance_pub]: https://pub.dartlang.org/packages/firebase_performance
[performance_product]: https://firebase.google.com/products/performance/
[performance_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_performance
[performance_badge]: https://img.shields.io/pub/v/firebase_performance.svg

[remote_config_pub]: https://pub.dartlang.org/packages/firebase_remote_config
[remote_config_product]: https://firebase.google.com/products/remote-config/
[remote_config_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_remote_config
[remote_config_badge]: https://img.shields.io/pub/v/firebase_remote_config.svg

[storage_pub]: https://pub.dartlang.org/packages/firebase_storage
[storage_product]: https://firebase.google.com/products/storage/
[storage_code]: https://github.com/flutter/plugins/tree/master/packages/firebase_storage
[storage_badge]: https://img.shields.io/pub/v/firebase_storage.svg

