# In App Purchase Example

Demonstrates how to use the In App Purchase Android (IAP) Plugin.

## Getting Started

### Preparation

There's a significant amount of setup required for testing in-app purchases
successfully, including registering new app IDs and store entries to use for
testing in the Play Developer Console. Google Play requires developers to 
configure an app with in-app items for purchase to call their in-app-purchase 
APIs. The Google Play Store has extensive documentation on how to do this, and 
we've also included a high level guide below.

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

   Make sure that all of the products are set to `ACTIVE`.

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
   