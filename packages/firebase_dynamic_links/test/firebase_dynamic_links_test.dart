// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseDynamicLinks', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      FirebaseDynamicLinks.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        final Map<dynamic, dynamic> returnUrl = <dynamic, dynamic>{
          'code': 1,
          'url': 'google.com',
        };
        switch (methodCall.method) {
          case 'DynamicLinkComponents#url':
            return "google.com";
          case 'DynamicLinkComponents#shortUrl':
            return returnUrl;
          case 'DynamicLinkComponents#shortenUrl':
            return returnUrl;
          default:
            return null;
        }
      });
      log.clear();
    });

    group('$DynamicLinkComponents', () {
      DynamicLinkComponents components;

      setUp(() {
        components = new DynamicLinkComponents(
            domain: 'test-domain', link: Uri.parse('test-link.com'));
      });

      test('shortenUrl', () async {
        final Uri url = Uri.parse("google.com");
        final DynamicLinkComponentsOptions options =
            new DynamicLinkComponentsOptions(
                shortDynamicLinkPathLength:
                    ShortDynamicLinkPathLength.unguessable);

        await DynamicLinkComponents.shortenUrl(url, options);

        expect(log, <Matcher>[
          isMethodCall("DynamicLinkComponents#shortenUrl",
              arguments: <String, dynamic>{
                'url': url.toString(),
                'dynamicLinkComponentsOptions': <String, dynamic>{
                  'shortDynamicLinkPathLength':
                      ShortDynamicLinkPathLength.unguessable.index,
                }
              }),
        ]);
      });

      test('$AndroidParameters', () async {
        components.androidParameters = new AndroidParameters(
          fallbackUrl: Uri.parse('test-url'),
          minimumVersion: 1,
          packageName: 'test-package',
        );

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': <String, dynamic>{
                  'fallbackUrl': 'test-url',
                  'minimumVersion': 1,
                  'packageName': 'test-package',
                },
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': <String, dynamic>{
                  'fallbackUrl': 'test-url',
                  'minimumVersion': 1,
                  'packageName': 'test-package',
                },
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
        ]);
      });

      test('$DynamicLinkComponentsOptions', () async {
        components.dynamicLinkComponentsOptions =
            new DynamicLinkComponentsOptions(
                shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short);

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': <String, dynamic>{
                  'shortDynamicLinkPathLength':
                      ShortDynamicLinkPathLength.short.index,
                },
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': <String, dynamic>{
                  'shortDynamicLinkPathLength':
                      ShortDynamicLinkPathLength.short.index,
                },
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
        ]);
      });

      test('$GoogleAnalyticsParameters', () async {
        components.googleAnalyticsParameters = new GoogleAnalyticsParameters(
          campaign: 'where',
          content: 'is',
          medium: 'my',
          source: 'cat',
          term: 'friend',
        );

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': <String, dynamic>{
                  'campaign': 'where',
                  'content': 'is',
                  'medium': 'my',
                  'source': 'cat',
                  'term': 'friend',
                },
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': <String, dynamic>{
                  'campaign': 'where',
                  'content': 'is',
                  'medium': 'my',
                  'source': 'cat',
                  'term': 'friend',
                },
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
        ]);
      });

      test('$IosParameters', () async {
        components.iosParameters = new IosParameters(
          appStoreId: 'is',
          bundleId: 'this',
          customScheme: 'the',
          fallbackUrl: Uri.parse('place'),
          ipadBundleId: 'to',
          ipadFallbackUrl: Uri.parse('find'),
          minimumVersion: 'potatoes',
        );

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': <String, dynamic>{
                  'appStoreId': 'is',
                  'bundleId': 'this',
                  'customScheme': 'the',
                  'fallbackUrl': 'place',
                  'ipadBundleId': 'to',
                  'ipadFallbackUrl': 'find',
                  'minimumVersion': 'potatoes',
                },
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': <String, dynamic>{
                  'appStoreId': 'is',
                  'bundleId': 'this',
                  'customScheme': 'the',
                  'fallbackUrl': 'place',
                  'ipadBundleId': 'to',
                  'ipadFallbackUrl': 'find',
                  'minimumVersion': 'potatoes',
                },
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
        ]);
      });

      test('$ItunesConnectAnalyticsParameters', () async {
        components.itunesConnectAnalyticsParameters =
            new ItunesConnectAnalyticsParameters(
          affiliateToken: 'hello',
          campaignToken: 'mister',
          providerToken: 'rose',
        );

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': <String, dynamic>{
                  'affiliateToken': 'hello',
                  'campaignToken': 'mister',
                  'providerToken': 'rose',
                },
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': <String, dynamic>{
                  'affiliateToken': 'hello',
                  'campaignToken': 'mister',
                  'providerToken': 'rose',
                },
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': null,
              }),
        ]);
      });

      test('$NavigationInfoParameters', () async {
        components.navigationInfoParameters =
            new NavigationInfoParameters(forcedRedirectEnabled: true);

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': <String, dynamic>{
                  'forcedRedirectEnabled': true,
                },
                'socialMetaTagParameters': null,
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': <String, dynamic>{
                  'forcedRedirectEnabled': true,
                },
                'socialMetaTagParameters': null,
              }),
        ]);
      });

      test('$SocialMetaTagParameters', () async {
        components.socialMetaTagParameters = new SocialMetaTagParameters(
          description: 'describe',
          imageUrl: Uri.parse('thisimage'),
          title: 'bro',
        );

        await components.url;
        await components.shortUrl;

        expect(log, <Matcher>[
          isMethodCall('DynamicLinkComponents#url',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': <String, dynamic>{
                  'description': 'describe',
                  'imageUrl': 'thisimage',
                  'title': 'bro',
                },
              }),
          isMethodCall('DynamicLinkComponents#shortUrl',
              arguments: <String, dynamic>{
                'androidParameters': null,
                'domain': 'test-domain',
                'dynamicLinkComponentsOptions': null,
                'googleAnalyticsParameters': null,
                'iosParameters': null,
                'itunesConnectAnalyticsParameters': null,
                'link': 'test-link.com',
                'navigationInfoParameters': null,
                'socialMetaTagParameters': <String, dynamic>{
                  'description': 'describe',
                  'imageUrl': 'thisimage',
                  'title': 'bro',
                },
              }),
        ]);
      });
    });
  });
}
