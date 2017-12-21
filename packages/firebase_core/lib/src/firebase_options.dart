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
    @required this.googleAppID,
    this.databaseURL,
    this.deepLinkURLScheme,
    this.storageBucket,
  })
      : assert(googleAppID != null);

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
  }

  /// An API key used for authenticating requests from your app, e.g.
  /// "AIzaSyDdVgKwhZl0sTTTLZ7iTmt1r3N2cJLnaDk", used to identify your app to
  /// Google servers.
  ///
  /// This property is required on Android.
  final String apiKey;

  /// The iOS bundle ID for the application. Defaults to
  /// `[[NSBundle mainBundle] bundleID]` when not set manually or in a plist.
  ///
  /// This property is used on iOS only.
  final String bundleID;

  /// The OAuth2 client ID for iOS application used to authenticate Google
  /// users, for example "12345.apps.googleusercontent.com", used for signing in
  /// with Google.
  ///
  /// This property is used on iOS only.
  final String clientID;

  /// The tracking ID for Google Analytics, e.g. "UA-12345678-1", used to
  /// configure Google Analytics.
  ///
  /// This property is used on iOS only.
  final String trackingID;

  /// The Project Number from the Google Developer’s console, for example
  /// "012345678901", used to configure Google Cloud Messaging.
  ///
  /// This property is required on iOS.
  final String gcmSenderID;

  /// The Project ID from the Firebase console, for example "abc-xyz-123."
  final String projectID;

  /// The Android client ID, for example "12345.apps.googleusercontent.com."
  ///
  /// This property is used on iOS only.
  final String androidClientID;

  /// The Google App ID that is used to uniquely identify an instance of an app.
  ///
  /// This property cannot be `null`.
  final String googleAppID;

  /// The database root URL, e.g. "http://abc-xyz-123.firebaseio.com."
  ///
  /// This property should be set for apps that use Firebase Database.
  final String databaseURL;

  /// The URL scheme used to set up Durable Deep Link service.
  ///
  /// This property is used on iOS only.
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
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseOptions) return false;
    return other.apiKey == apiKey &&
        other.bundleID == bundleID &&
        other.clientID == clientID &&
        other.trackingID == trackingID &&
        other.gcmSenderID == gcmSenderID &&
        other.projectID == projectID &&
        other.androidClientID == androidClientID &&
        other.googleAppID == googleAppID &&
        other.databaseURL == databaseURL &&
        other.deepLinkURLScheme == deepLinkURLScheme &&
        other.storageBucket == storageBucket;
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
