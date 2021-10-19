# In App Purchase Example

Demonstrates how to use the In App Purchase (IAP) Plugin.

## Getting Started

### Preparation

There's a significant amount of setup required for testing in app purchases
successfully, including registering new app IDs and store entries to use for
testing in both the Play Developer Console and App Store Connect. Both Google
Play and the App Store require developers to configure an app with in-app items
for purchase to call their in-app-purchase APIs. Both stores have extensive
documentation on how to do this, and we've also included a high level guide
below.

* [In-App Purchase (App Store)](https://developer.apple.com/in-app-purchase/)
* [Google Play Billing Overview](https://developer.android.com/google/play/billing/billing_overview)

### Android

1. Create a new app in the [Play Developer
   Console](https://play.google.com/apps/publish/) (PDC).

2. Sign up for a merchant's account in the PDC.

3. Create IAPs in the PDC available for purchase in the app. The example assumes
   the following SKU IDs exist:

   - `consumable`: A managed product.
   - `upgrade`: A managed product.
   - `subscription_silver`: A lower level subscription.
   - `subscription_gold`: A higher level subscription.

   Make sure that all the products are set to `ACTIVE`.

4. Update `APP_ID` in `example/android/app/build.gradle` to match your package
   ID in the PDC.

5. Create an `example/android/keystore.properties` file with all your signing
   information. `keystore.example.properties` exists as an example to follow.
   It's impossible to use any of the `BillingClient` APIs from an unsigned APK.
   See
   [here](https://developer.android.com/studio/publish/app-signing#secure-shared-keystore)
   and [here](https://developer.android.com/studio/publish/app-signing#sign-apk)
   for more information.

6. Build a signed apk. `flutter build apk` will work for this, the gradle files
   in this project have been configured to sign even debug builds.

7. Upload the signed APK from step 6 to the PDC, and publish that to the alpha
   test channel. Add your test account as an approved tester. The
   `BillingClient` APIs won't work unless the app has been fully published to
   the alpha channel and is being used by an authorized test account. See
   [here](https://support.google.com/googleplay/android-developer/answer/3131213)
   for more info.

8. Sign in to the test device with the test account from step #7. Then use
   `flutter run` to install the app to the device and test like normal.

### iOS

When using Xcode 12 and iOS 14 or higher you can run the example in the simulator or on a device without 
having to configure an App in App Store Connect. The example app is set up to use StoreKit Testing configured
in the `example/ios/Runner/Configuration.storekit` file (as documented in the article [Setting Up StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting_up_storekit_testing_in_xcode?language=objc)).
To run the application take the following steps (note that it will only work when running from Xcode):

1. Open the example app with Xcode, `File > Open File` `example/ios/Runner.xcworkspace`;

2. Within Xcode edit the current scheme, `Product > Scheme > Edit Scheme...` (or press `Command + Shift + ,`);

3. Enable StoreKit testing:
  a. Select the `Run` action;
  b. Click `Options` in the action settings;
  c. Select the `Configuration.storekit` for the StoreKit Configuration option.

4. Click the `Close` button to close the scheme editor;

5. Select the device you want to run the example App on;

6. Run the application using `Product > Run` (or hit the run button).

When testing on pre-iOS 14 you can't run the example app on a simulator and you will need to configure an app in App Store Connect. You can do so by following the steps below:

1. Follow ["Workflow for configuring in-app
   purchases"](https://help.apple.com/app-store-connect/#/devb57be10e7), a
   detailed guide on all the steps needed to enable IAPs for an app. Complete
   steps 1 ("Sign a Paid Applications Agreement") and 2 ("Configure in-app
   purchases").

   For step #2, "Configure in-app purchases in App Store Connect," you'll want
   to create the following products:

   - A consumable with product ID `consumable`
   - An upgrade with product ID `upgrade`
   - An auto-renewing subscription with product ID `subscription_silver`
   - An non-renewing subscription with product ID `subscription_gold`

2. In XCode, `File > Open File` `example/ios/Runner.xcworkspace`. Update the
   Bundle ID to match the Bundle ID of the app created in step #1.

3. [Create a Sandbox tester
   account](https://help.apple.com/app-store-connect/#/dev8b997bee1) to test the
   in-app purchases with.

4. Use `flutter run` to install the app and test it. Note that you need to test
   it on a real device instead of a simulator. Next click on one of the products
   in the example App, this enables the "SANDBOX ACCOUNT" section in the iOS
   settings. You will now be asked to sign in with your sandbox test account to
   complete the purchase (no worries you won't be charged). If for some reason
   you aren't asked to sign-in or the wrong user is listed, go into the iOS
   settings ("Settings" -> "App Store" -> "SANDBOX ACCOUNT") and update your
   sandbox account from there. This procedure is explained in great detail in
   the [Testing In-App Purchases with Sandbox](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox?language=objc) article.


**Important:** signing into any production service (including iTunes!) with the
sandbox test account will permanently invalidate it.
