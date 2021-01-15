# espresso_example

Demonstrates how to use the espresso package.

The espresso package only runs tests on Android. The example runs on iOS, but this is only to keep our continuous integration bots green.

## Getting Started

To run the Espresso tests:

```
flutter build apk --debug
./gradlew app:connectedAndroidTest
```
