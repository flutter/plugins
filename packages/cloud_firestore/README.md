# Cloud Firestore Plugin for Flutter

A Flutter plugin to use the [Cloud Firestore API](https://firebase.google.com/docs/firestore/).

[![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dartlang.org/packages/cloud_firestore)

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

Recent versions (0.3.x and 0.4.x) of this plugin require [extensible codec functionality](https://github.com/flutter/flutter/pull/15414) that is not yet released to the [beta channel](https://github.com/flutter/flutter/wiki/Flutter-build-release-channels) of Flutter. If you're encountering issues using those versions, consider switching to the dev channel.

## Setup

To use this plugin:

1. Using the [Firebase Console](http://console.firebase.google.com/), add an Android app to your project:
Follow the assistant, download the generated google-services.json file and place it inside android/app. Next,
modify the android/build.gradle file and the android/app/build.gradle file to add the Google services plugin
as described by the Firebase assistant. Ensure that your `android/build.gradle` file contains the
`maven.google.com` as [described here](https://firebase.google.com/docs/android/setup#add_the_sdk).
1. Using the [Firebase Console](http://console.firebase.google.com/), add an iOS app to your project:
Follow the assistant, download the generated GoogleService-Info.plist file, open ios/Runner.xcworkspace
with Xcode, and within Xcode place the file inside ios/Runner. Don't follow the steps named
"Add Firebase SDK" and "Add initialization code" in the Firebase assistant.
1. Add `cloud_firestore` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Usage

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('books').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['title']),
                  subtitle: new Text(document['author']),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
```

Performing a query:
```dart
Firestore.instance
    .collection('talks')
    .where("topic", isEqualTo: "flutter")
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) => print(doc["title"])));
```

Running a transaction:

```dart
final DocumentReference postRef = Firestore.instance.document('posts/123');
Firestore.instance.runTransaction((Transaction tx) async {
  DocumentSnapshot postSnapshot = await tx.get(postRef);
  if (postSnapshot.exists) {
    await tx.update(postRef, <String, dynamic>{'likesCount': postSnapshot.data['likesCount'] + 1});
  }
});
```

## Getting Started

See the `example` directory for a complete sample app using Cloud Firestore.
