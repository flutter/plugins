# firebase_auth_example

[![pub package](https://img.shields.io/pub/v/firebase_auth.svg)](https://pub.dartlang.org/packages/firebase_auth)

Demonstrates how to use the firebase_auth plugin.

## Phone Auth

1. Enable phone authentication in the [Firebase console]((https://console.firebase.google.com/u/0/project/_/authentication/providers)).
1. Add test phone number and verification code to the Firebase console.
  - For this sample the number `+1 408-555-6969` and verification code `888888` are used.
1. For iOS set the `URL Schemes` to the `REVERSE_CLIENT_ID` from the `GoogleServices-Info.plist` file.
1. Click the `Test verifyPhoneNumber` button.
  - If APNs is not enabled or a simulator is being used, verification
    will be done via a Captcha.
1. Once the phone number is verified the app displays the test 
   verification code.
1. Click the `Test signInWithPhoneNumber` button.
1. Signed in user's details are displayed in the UI.
   

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).
