# Firestore Plugin for Flutter

Confidential Material: This page is confidential. Do not share or discuss until authorized to do so.

Contact jackson@google.com for more information about this plugin.

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

## Usage

To use this plugin, add `firestore` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

You will need to unzip the prerelease Firestore Android SDK into `$HOME/.m2/repository` and ensure that `mavenLocal()` is included
in your app's `build.gradle`, after `jcenter()`, in the `allProjects` section.

On iOS, you will need to add this to `ios/Podfile`:

```
  pod 'Firestore', :podspec => 'https://storage.googleapis.com/firebase-preview-drop/ios/firestore/0.6.4/Firestore.podspec.json'
```

Adding a new `DocumentReference`:

```dart
    await Firestore.instance.collection('books').document().setData(<String, String>{
      'title': title,
      'author': author,
    });
```

Binding a `DocumentCollection` to a `ListView`:

```dart
class BookList extends StatelessWidget {
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('books').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
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
