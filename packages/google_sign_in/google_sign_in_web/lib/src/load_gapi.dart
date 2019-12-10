// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library gapi_onload;

import 'dart:async';

import 'package:js/js.dart';
import 'package:meta/meta.dart';

import 'generated/gapi.dart' as gapi;
import 'utils.dart' show injectJSLibraries;

@JS()
external set gapiOnloadCallback(Function callback);

// This name must match the external setter above
/// This is only exposed for testing. It shouldn't be accessed by users of the
/// plugin as it could break at any point.
@visibleForTesting
const String kGapiOnloadCallbackFunctionName = "gapiOnloadCallback";
String _addOnloadToScript(String url) => url.startsWith('data:')
    ? url
    : '$url?onload=$kGapiOnloadCallbackFunctionName';

/// Injects the GAPI library by its [url], and other additional [libraries].
///
/// GAPI has an onload API where it'll call a callback when it's ready, JSONP style.
Future<void> inject(String url, {List<String> libraries = const <String>[]}) {
  // Inject the GAPI library, and configure the onload global
  final Completer<void> gapiOnLoad = Completer<void>();
  gapiOnloadCallback = allowInterop(() {
    // Funnel the GAPI onload to a Dart future
    gapiOnLoad.complete();
  });

  // Attach the onload callback to the main url
  final List<String> allLibraries = <String>[_addOnloadToScript(url)]
    ..addAll(libraries);

  return Future.wait(
      <Future<void>>[injectJSLibraries(allLibraries), gapiOnLoad.future]);
}

/// Initialize the global gapi object so 'auth2' can be used.
/// Returns a promise that resolves when 'auth2' is ready.
Future<void> init() {
  final Completer<void> gapiLoadCompleter = Completer<void>();
  gapi.load('auth2', allowInterop(() {
    gapiLoadCompleter.complete();
  }));

  // After this resolves, we can use gapi.auth2!
  return gapiLoadCompleter.future;
}
