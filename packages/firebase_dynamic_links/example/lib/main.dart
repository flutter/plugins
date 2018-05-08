import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> _getDynamicLink() async {
    final DynamicLinkComponents components = new DynamicLinkComponents(
        domain: "cx4k7.app.goo.gl", link: Uri.parse("https://google.com"));

    components.androidParameters = new AndroidParameters(
      packageName: "io.flutter.plugins.firebasedynamiclinksexample",
      fallbackUrl: Uri.parse("google.com"),
      minimumVersion: 23,
    );

    components.googleAnalyticsParameters = new GoogleAnalyticsParameters(
      campaign: "champagne",
      medium: "middle",
      source: "src",
      content: "tentpent",
      term: "midterm",
    );

    components.iosParameters = new IosParameters(
      bundleId: "poopId",
      appStoreId: "storeApp",
      customScheme: "schleme",
      fallbackUrl: Uri.parse("uallback"),
      ipadBundleId: "budleIpad",
      ipadFallbackUrl: Uri.parse("fallbackurlipad"),
      minimumVersion: "version16",
    );

    components.itunesConnectAnalyticsParameters = new ItunesConnectAnalyticsParameters(
      affiliateToken: "affi",
      campaignToken: "campagne",
      providerToken: "provide",
    );

    components.navigationInfoParameters = new NavigationInfoParameters(
      forcedRedirectEnabled: true,
    );

    components.socialMetaTagParameters = new SocialMetaTagParameters(
      description: "describe",
      imageUrl: Uri.parse("internet"),
      title: "tits",
    );

    final Uri uri = await components.uri;
    print(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(
              onPressed: _getDynamicLink, child: const Text("Create Link")),
        ),
      ),
    );
  }
}
