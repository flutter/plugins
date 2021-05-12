# In App Purchase iOS Example

Demonstrates how to use the In App Purchase iOS (IAP) Plugin.

## Getting Started

### Preparation

There's a significant amount of setup required for testing in app purchases
successfully, including registering new app IDs and store entries to use for
testing in App Store Connect. The App Store requires developers to configure 
an app with in-app items for purchase to call their in-app-purchase APIs. 
The App Store has extensive documentation on how to do this, and we've also 
included a high level guide below.

* [In-App Purchase (App Store)](https://developer.apple.com/in-app-purchase/)

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
