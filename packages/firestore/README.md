# Firestore Plugin for Flutter

A Flutter plugin to use the [Firestore API](https://firebase.google.com/docs/firestore/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Setup

To use this plugin:

1. Using the [Firebase Console](http://console.firebase.google.com/), add an Android app to your project: Follow the assistant, download the generated google-services.json file and place it inside android/app. Next, modify the android/build.gradle file and the android/app/build.gradle file to add the Google services plugin as described by the Firebase assistant. Ensure that your `android/build.gradle` file contains the `maven.google.com` as [described here](https://firebase.google.com/docs/android/setup#add_the_sdk).
1. Using the [Firebase Console](http://console.firebase.google.com/), add an iOS app to your project: Follow the assistant, download the generated GoogleService-Info.plist file, open ios/Runner.xcworkspace with Xcode, and within Xcode place the file inside ios/Runner. Don't follow the steps named "Add Firebase SDK" and "Add initialization code" in the Firebase assistant.
1. Add `firebase_firestore` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Usage

```dart
import 'package:firebase_firestore/firebase_firestore.dart';
```

Adding a new `DocumentReference`:

```dart
Firestore.instance.collection('books').document()
  .setData({ 'title': 'title', 'author': 'author' });
```

Binding a `CollectionReference` to a `ListView`:

```dart
class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('books').snapshots,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((document) {
            return new ListTile(
              title: new Text(document['title']),
              subtitle: new Text(document['author']),
            );
          }).toList(),
        );
      },
    );
  }
}
```

## Getting Started

See the `example` directory for a complete sample app using Firestore.
