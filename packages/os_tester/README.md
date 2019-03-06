# os_tester

OSTester is a Flutter plugin that enables you to write clear, concise UI tests.

This plugin provides access to enhanced synchronization features.

Tests automatically synchronize with the UI, network requests, and various queues.

EarlGrey works in conjunction with the XCTest framework and integrates with Xcode’s Test Navigator so you can run tests directly from Xcode or the command line (using xcodebuild).

It is implemented using EarlGrey on iOS. An Espresso-based Android backend is planned.

## Running the example

The first time you will need to `flutter run`. This ensures that the CocoaPods have been installed.

Open ios/Runner.xcworkspace to open the example in Xcode and select Product > Test.
You should see a message showing the that the test passed.

Alternatively, you can run the example from the command line:

```bash
xcodebuild -project Runner.xcodeproj/ -scheme OSTesterTests -destination "OS=8.1,name=iPhone X" -configuration Debug ONLY_ACTIVE_ARCH=NO test
```

## Using os_tester in your own project

You can instrument your own app to test in the same way as the example. Detailed instructions are coming soon.
