// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_core;

class FirebaseOptions {

  const FirebaseOptions({
    this.apiKey,
    this.bundleID,
    this.clientID,
    this.trackingID,
    this.gcmSenderID,
    this.projectID,
    this.androidClientID,
    this.googleAppID,
    this.databaseURL,
    this.deepLinkURLScheme,
    this.storageBucket,
  });

  @visibleForTesting
  FirebaseOptions.from(Map<String, String> map)
      : apiKey = map['APIKey'],
        bundleID = map['bundleID'],
        clientID = map['clientID'],
        trackingID = map['trackingID'],
        gcmSenderID = map['GCMSenderID'],
        projectID = map['projectID'],
        androidClientID = map['androidClientID'],
        googleAppID = map['googleAppID'],
        databaseURL = map['databaseURL'],
        deepLinkURLScheme = map['deepLinkURLScheme'],
        storageBucket = map['storageBucket'] {
    assert(googleAppID != null);
    assert(gcmSenderID != null);
  }

  /// An API key used for authenticating requests from your app, e.g.
  /// "AIzaSyDdVgKwhZl0sTTTLZ7iTmt1r3N2cJLnaDk", used to identify your app to
  /// Google servers.
  final String apiKey;

  /// The iOS bundle ID for the application. Defaults to
  /// [[NSBundle mainBundle] bundleID] when not set manually or in a plist.
  final String bundleID;

  /// The OAuth2 client ID for iOS application used to authenticate Google
  /// users, for example "12345.apps.googleusercontent.com", used for signing in
  /// with Google.
  final String clientID;

  /// The tracking ID for Google Analytics, e.g. "UA-12345678-1", used to
  /// configure Google Analytics.
  final String trackingID;

  /// The Project Number from the Google Developer’s console, for example
  /// "012345678901", used to configure Google Cloud Messaging.
  final String gcmSenderID;

  /// The Project ID from the Firebase console, for example "abc-xyz-123."
  final String projectID;

  /// The Android client ID, for example "12345.apps.googleusercontent.com."
  final String androidClientID;

  /// The Google App ID that is used to uniquely identify an instance of an app.
  final String googleAppID;

  /// The database root URL, e.g. "http://abc-xyz-123.firebaseio.com."
  final String databaseURL;

  /// The URL scheme used to set up Durable Deep Link service.
  final String deepLinkURLScheme;

  /// The Google Cloud Storage bucket name, e.g.
  /// "abc-xyz-123.storage.firebase.com."
  final String storageBucket;

  @visibleForTesting
  Map<String, String> get asMap {
    return <String, String>{
      'APIKey': apiKey,
      'bundleID': bundleID,
      'clientID': clientID,
      'trackingID': trackingID,
      'gcmSenderID': gcmSenderID,
      'projectID': projectID,
      'androidClientID': androidClientID,
      'googleAppID': googleAppID,
      'databaseURL': databaseURL,
      'deepLinkURLScheme': deepLinkURLScheme,
      'storageBucket': storageBucket,
    };
  }

  @override
  bool operator==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other is! FirebaseOptions)
      return false;
    return other.apiKey == apiKey
       && other.bundleID == bundleID
       && other.clientID == clientID
       && other.trackingID == trackingID
       && other.gcmSenderID == gcmSenderID
       && other.projectID == projectID
       && other.androidClientID == androidClientID
       && other.googleAppID == googleAppID
       && other.databaseURL == databaseURL
       && other.deepLinkURLScheme == deepLinkURLScheme
       && other.storageBucket == storageBucket;
  }

  @override
  int get hashCode {
    return hashValues(
      apiKey,
      bundleID,
      clientID,
      trackingID,
      gcmSenderID,
      projectID,
      androidClientID,
      googleAppID,
      databaseURL,
      deepLinkURLScheme,
      storageBucket,
    );
  }

  @override
  String toString() => asMap.toString();
}
